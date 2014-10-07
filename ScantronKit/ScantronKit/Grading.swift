//
//  Grading.swift
//  ScantronKit
//
//  Created by Nate Parrott on 9/21/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

import Foundation

typealias QuizItem = [String: AnyObject]

func CreateQuizInstance(quiz: Quiz, pages: [ScannedPage], manuallyGradedResponses: [QuizItemManuallyGradedResponse?]) -> QuizInstance {
    let instance = SharedCoreDataManager().newEntity("QuizInstance") as QuizInstance
    instance.quiz = quiz
    instance.uuid = NSUUID().UUIDString
    let createPageImage = {
        (page: ScannedPage) -> PageImage in
        let entity = SharedCoreDataManager().newEntity("PageImage") as PageImage
        let data = UIImageJPEGRepresentation(page.image, 0.1)
        entity.data = data
        return entity
    }
    instance.pageImages = NSOrderedSet(array: pages.map({ createPageImage($0) }))
    
    let itemsWithResponses = quiz.generateResponseItemsWithScannedPages(pages, manuallyGradedResponses: manuallyGradedResponses)
    instance.itemsWithResponses = itemsWithResponses
    let grade = GenerateGradeForItemsWithResponses(itemsWithResponses)
    instance.earnedScore = grade.points
    instance.maximumScore = grade.total
    instance.date = NSDate()
    
    return instance
}

func GenerateGradeForItemsWithResponses(items: [QuizItem]) -> (points: Double, total: Double) {
    var points: Double = 0
    var total: Double = 0
    for item in items {
        if let pointsForItem = item.get("points") as? Double {
            total += pointsForItem
            if let earned = item.get("pointsEarned") as? Double {
                points += earned
            }
        }
    }
    return (points: points, total: total)
}

extension Quiz {
    func generateResponseItemsWithScannedPages(pages: [ScannedPage], manuallyGradedResponses: [QuizItemManuallyGradedResponse?]) -> [QuizItem] {
        let json = self.json as [String: AnyObject]
        let items = json.getOrDefault("items", defaultVal: []) as [QuizItem]
        return map(Zip2(items, manuallyGradedResponses), { AddResponseInfoForItem($0.0, $0.1, pages) })
    }
}

func AddResponseInfoForItem(var item: QuizItem, manuallyGraded: QuizItemManuallyGradedResponse?, pages: [ScannedPage]) -> QuizItem {
    let type = item.getOrDefault("type", defaultVal: "") as String
    switch type {
    case "multiple-choice":
        let frames = (item.getOrDefault("frames", defaultVal: []) as [[Double]]).map({ QuizItemFrame(array: $0) })
        let correctResponse = item.getOrDefault("correct", defaultVal: 0) as Int
        if let response = indexOfFilledInFrame(frames, pages) {
            item["pointsEarned"] = response == correctResponse ? item.getOrDefault("points", defaultVal: 0) as Double : 0
            item["response"] = response
        } else {
            item["pointsEarned"] = 0
            item["response"] = NSNull()
        }
    case "true-false":
        let frames = (item.getOrDefault("frames", defaultVal: []) as [[Double]]).map({ QuizItemFrame(array: $0) })
        let correctResponse = item.getOrDefault("correct", defaultVal: true) as Bool
        let filledIn = indexOfFilledInFrame(frames, pages)
        if filledIn != nil && filledIn! != 2 {
            let response = filledIn! == 0
            item["pointsEarned"] = response == correctResponse ? item.getOrDefault("points", defaultVal: 0) as Double : 0
            item["response"] = response
        } else {
            item["pointsEarned"] = 0
            item["response"] = NSNull()
        }
    case "free-response":
        item["pointsEarned"] = manuallyGraded!.earnedPoints!
    default: 0
    }
    item["gradingDescription"] = ResponseDescriptionStringForGradedQuizItem(item)
    return item
}

func QuizItemNeedsResponse(item: QuizItem) -> Bool {
    return (item.getOrDefault("type", defaultVal: "") as String) == "free-response"
}

extension Quiz {
    var quizItems: [QuizItem] {
        get {
            let json = self.json as [String: AnyObject]
            return json.getOrDefault("items", defaultVal: []) as [QuizItem]
        }
    }
    func getManuallyGradedResponseTemplates() -> [QuizItemManuallyGradedResponse?] {
        return self.quizItems.map() {
            (item: QuizItem) in
            if QuizItemNeedsResponse(item) {
                return QuizItemManuallyGradedResponse(item: item)
            } else {
                return nil
            }
        }
    }
    var canGradeAutomatically: Bool {
        get {
            return countElements(getManuallyGradedResponseTemplates().filter({ $0 != nil })) == 0
        }
    }
    var aspectRatio: CGFloat {
        get {
            return (self.json as [String: AnyObject]).getOrDefault("aspectRatio", defaultVal: 1.0) as CGFloat
        }
    }
}

class QuizItemManuallyGradedResponse {
    init(item: QuizItem) {
        self.item = item
        frame = QuizItemFrame(array: item.getOrDefault("frame", defaultVal: []) as [Double])
        pointValue = item.getOrDefault("points", defaultVal: 0.0) as Double
    }
    var frame: QuizItemFrame
    var item: QuizItem
    var pointValue: Double
    var earnedPoints: Double?
}

struct QuizItemFrame {
    init(array: [Double]) {
        page = Int(array[0])
        left = array[1]
        top = array[2]
        right = array[3]
        bottom = array[4]
    }
    var page: Int
    var left, top, right, bottom: Double
    func toRect(size: CGSize) -> CGRect {
        return CGRectMake(CGFloat(left) * size.width, CGFloat(top) * size.height, CGFloat(right - left) * size.width, CGFloat(bottom - top) * size.height)
    }
    func extract(image: UIImage, aspectRatio: CGFloat) -> UIImage {
        let rect = toRect(image.size)
        let image = image.subImage(rect)
        var imageSize = image.size
        if aspectRatio > 1 {
            imageSize.width *= aspectRatio
        } else {
            imageSize.height /= aspectRatio
        }
        return image.resizeTo(imageSize)
    }
}

/*func indexOfDarkestFrame(frames: [QuizItemFrame], pages: [ScannedPage]) -> Int {
    // TODO: support lists of frames spanning multiple pages
    let image = pages[frames.first!.page].image
    let pixels = image.pixelData()
    let brightnesses = frames.map({ pixels.averageBrightnessInRect($0.toRect(image.size)) })
    let darkestIndex = sorted(Array(0..<countElements(frames)), { brightnesses[$0] < brightnesses[$1] }).first!
    return darkestIndex
}*/

func indexOfFilledInFrame(frames: [QuizItemFrame], pages: [ScannedPage]) -> Int? {
    // TODO: support lists of frames spanning multiple pages
    let image = pages[frames.first!.page].image
    let pixels = image.pixelData()
    let brightnesses = frames.map({ pixels.averageBrightnessInRect($0.toRect(image.size)) })
    return indexOfOutlier(brightnesses)
}

extension QuizInstance {
    @objc func nameImage() -> UIImage? {
        let quizItems = (quiz.json as [String: AnyObject]).get("items")! as [QuizItem]
        var nameItemOpt = quizItems.filter({ ($0.get("type")! as String) == "name-field" }).first
        if let nameItem = nameItemOpt {
            let frame = QuizItemFrame(array: nameItem.get("frame")! as [Double])
            let pageImage = UIImage(data: (pageImages[0] as PageImage).data)
            return frame.extract(pageImage, aspectRatio: quiz.aspectRatio)
        }
        return nil
    }
}

func ResponseDescriptionStringForGradedQuizItem(item: QuizItem) -> String? {
    let type = item.getOrDefault("type", defaultVal: "") as String
    var s = ""
    let earned = item.getOrDefault("pointsEarned", defaultVal: 0) as Double
    let maxPoints = item.getOrDefault("points", defaultVal: 0) as Double
    switch type {
        case "true-false":
            let correct = item.getOrDefault("correct", defaultVal: false) as Bool
            if let response = item.getOrDefault("response", defaultVal: false) as? Bool {
                if correct == response {
                    s = response ? "Correctly answered 'true'" : "Correctly answered 'false'"
                } else {
                    s = response ? "Answered 'true', the correct answer was 'false'" : "Answered 'false', the correct answer was 'true'"
                }
            } else {
                s = "Answer was blank"
        }
        case "multiple-choice":
            let letters = "ABCDEFGHIJKLMNOPQRSTUVWYZ"
            let correctIndex = item.getOrDefault("correct", defaultVal: 0) as Int
            if let responseIndex = item.getOrDefault("response", defaultVal: 0) as? Int {
                let correct = letters.substring(correctIndex, length: 1)
                let response = letters.substring(responseIndex, length: 1)
                if correctIndex == responseIndex {
                    s = "Correctly answered '\(correct)'"
                } else {
                    s = "Answered '\(response)'; the correct answer was '\(correct)'"
                }
            } else {
                s = "Answer was blank"
        }
        case "free-response":
            s = "You gave this \(earned)/\(maxPoints) points"
    default: 0
    }
    return s
}

