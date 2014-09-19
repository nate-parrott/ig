//
//  ScantronKitTests.swift
//  ScantronKitTests
//
//  Created by Nate Parrott on 7/30/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

import XCTest
import InstaGrade_Scanner

class ScantronKitTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    func testTestbed() {
        //SKTestbed().test()
    }
    
    func testBarcode() {
        let path = "/Users/nateparrott/Documents/SW/Instagrade2/ScantronKit/tests/barcode tests/8083890.png"
        let image = UIImage(contentsOfFile: path)
        extractScannedPage(image) {
            (page: ScannedPage?) in
            if let p = page {
                let b = p.barcode
                println("Page #: \(b.pageNum), index: \(b.index)")
            } else {
                println("failed to scan")
            }
        }
    }
    
}
