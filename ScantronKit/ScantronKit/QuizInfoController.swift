//
//  QuizInfoController.swift
//  ScantronKit
//
//  Created by Nate Parrott on 9/20/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

import UIKit

class QuizInfoController: NSObject {
    var pages: [ScannedPage] = []
    var quiz: Quiz?
    
    func addPage(page: ScannedPage) {
        if SharedAPI().queriedQuizIds.contains(page.barcode.index) {
            // don't fetch again; only handle if this quiz is present locally:
            if let quiz = SharedAPI().findLocalQuizWithIndex(page.barcode.index) {
                addPage(page, withQuiz: quiz)
            } else {
                unknownIndex(page.barcode.index)
            }
        } else {
            loadingCount++
            SharedAPI().fetchQuizWithIndex(page.barcode.index) {
                quizOpt in
                self.loadingCount--
                if let quiz = quizOpt {
                    self.addPage(page, withQuiz: quiz)
                } else {
                    self.unknownIndex(page.barcode.index)
                }
            }
        }
    }
    
    func unknownIndex(index: Int) {
        // todo: somehow relay this to the user after a certain amount of time?
        print("Unknown index code \(index)")
    }
    
    func addPage(page: ScannedPage, withQuiz: Quiz) {
        if self.quiz == nil || self.quiz!.index == withQuiz.index {
            if pages.count != page.barcode.pageNum + 1 {
                if page.barcode.pageNum == pages.count {
                    pages.append(page)
                    quiz = withQuiz
                    if pages.count == withQuiz.totalPages() {
                        status = .Done
                        needsGrading()
                    } else {
                        status = .PartialScan(pages: pages.count, total: withQuiz.totalPages())
                    }
                } else {
                    if let show = onShowAdvisoryMessage {
                        show("This looks like page #\(page.barcode.pageNum + 1) of a quiz, but the last page you scanned was page #\(pages.count)")
                    }
                }
            } else {
                // this is just a re-scan of the last scanned page; see if it's less blurry:
                if page.blurriness < pages[pages.count - 1].blurriness {
                    pages[pages.count - 1] = page
                    needsGrading()
                }
            }
        } else {
            if let show = onShowAdvisoryMessage {
                show("This looks like a different quiz from the one you just scanned.")
            }
        }
    }
    
    var lastClearedDate: NSTimeInterval = 0
    func clear() {
        pages = []
        quiz = nil
        status = .None
        lastGradeForThisScan = nil
        currentlyGrading = false
        lastClearedDate = NSDate.timeIntervalSinceReferenceDate()
        manualResponseItems = nil
    }
    
    enum Status : CustomStringConvertible, Equatable {
        case None
        case PartialScan(pages: Int, total: Int)
        case Done
        var description : String {
            get {
                switch self {
                case .None: return "None"
                case .PartialScan(pages: let pages, total: let total): return "PartialScan(\(pages) / \(total))"
                case .Done: return "Done"
                }
            }
        }
    }
    
    var status: Status = .None {
        didSet {
            if let callback = onStatusChanged {
                callback()
            }
        }
    }
    
    var loadingCount: Int = 0 {
        didSet {
            if let callback = onStatusChanged {
                callback()
            }
        }
    }
    // MARK: Grading
    var lastGradeForThisScan: [QuizItem]? {
        didSet {
            if let callback = onStatusChanged {
                callback()
            }
        }
    }
    var currentlyGrading: Bool = false {
        didSet {
            if let callback = onStatusChanged {
                callback()
            }
        }
    }
    private var needsGradingAfter: Bool = false
    private func needsGrading() {
        if quiz != nil {
            if quiz!.canGradeAutomatically || manualResponseItems != nil {
                if currentlyGrading {
                    needsGradingAfter = true
                } else {
                    gradeNow()
                }
            }
        }
    }
    var manualResponseItems: [QuizItemManuallyGradedResponse?]? {
        didSet {
            needsGrading()
        }
    }
    private func gradeNow() {
        currentlyGrading = true
        let quiz = self.quiz!
        let pages = self.pages
        let startedDate = NSDate.timeIntervalSinceReferenceDate()
        let responseItems = manualResponseItems != nil ? manualResponseItems! : quiz.getManuallyGradedResponseTemplates()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
            let gradedItems = quiz.generateResponseItemsWithScannedPages(pages, manuallyGradedResponses: responseItems)
            AsyncOnMainQueue() {
                if self.lastClearedDate < startedDate {
                    self.lastGradeForThisScan = gradedItems
                }
                self.currentlyGrading = false
                if self.needsGradingAfter {
                    self.needsGradingAfter = false
                    self.needsGrading()
                }
            }
        })
    }
    
    // MARK: Callbacks
    var onStatusChanged: (() -> ())?
    var onShowAdvisoryMessage: ((String) -> ())?
    
    func createGradedQuizInstance() -> QuizInstance {
        let manualResponses = self.manualResponseItems != nil ? self.manualResponseItems! : quiz!.getManuallyGradedResponseTemplates()
        return CreateQuizInstance(quiz!, pages: pages, manuallyGradedResponses: manualResponses)
    }
}

func ==(lhs: QuizInfoController.Status, rhs: QuizInfoController.Status) -> Bool {
    switch (lhs, rhs) {
    case (.None, .None): return true
    case (.Done, .Done): return true
    case (.PartialScan(pages: let p1, total: let t1), .PartialScan(pages: let p2, total: let t2)): return p1 == p2 && t1 == t2
    default: return false
    }
}

