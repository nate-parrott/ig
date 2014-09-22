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
        println("Unknown index code \(index)")
    }
    
    func addPage(page: ScannedPage, withQuiz: Quiz) {
        if self.quiz == nil || self.quiz!.index == withQuiz.index {
            if countElements(pages) != page.barcode.pageNum + 1 {
                if page.barcode.pageNum == countElements(pages) {
                    pages.append(page)
                    quiz = withQuiz
                    if countElements(pages) == withQuiz.totalPages() {
                        status = .Done
                    } else {
                        status = .PartialScan(pages: countElements(pages), total: withQuiz.totalPages())
                    }
                } else {
                    if let show = onShowAdvisoryMessage {
                        show("This looks like page #\(page.barcode.pageNum + 1) of a quiz, but the last page you scanned was page #\(countElements(pages))")
                    }
                }
            } else {
                // this is just a re-scan of the last scanned page; see if it's less blurry:
                if page.blurriness < pages[countElements(pages) - 1].blurriness {
                    pages[countElements(pages) - 1] = page
                }
            }
        } else {
            if let show = onShowAdvisoryMessage {
                show("This looks like a different quiz from the one you just scanned.")
            }
        }
    }
    
    func clear() {
        pages = []
        quiz = nil
        status = .None
    }
    
    enum Status : Printable, Equatable {
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
    
    var onStatusChanged: (() -> ())?
    var onShowAdvisoryMessage: ((String) -> ())?
}

func ==(lhs: QuizInfoController.Status, rhs: QuizInfoController.Status) -> Bool {
    switch (lhs, rhs) {
    case (.None, .None): return true
    case (.Done, .Done): return true
    case (.PartialScan(pages: let p1, total: let t1), .PartialScan(pages: let p2, total: let t2)): return p1 == p2 && t1 == t2
    default: return false
    }
}

