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
    var quizDownloadTask: NSURLSessionDataTask?
    
    func addPage(page: ScannedPage) {
        loadingCount++
        SharedAPI().getQuizWithIndex(page.barcode.index) {
            quizOpt in
            self.loadingCount--
            if let quiz = quizOpt {
                self.addPage(page, withQuiz: quiz)
            } else {
                // todo: somehow relay this to the user after a certain amount of time?
                println("Unknown index code \(page.barcode.index)")
            }
        }
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
                // ignore; this is just a re-scan of the last scanned page
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
        if let task = quizDownloadTask {
            task.cancel()
            quizDownloadTask = nil
        }
    }
    
    enum Status : Printable {
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
