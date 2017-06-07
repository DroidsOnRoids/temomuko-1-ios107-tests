//
//  SnapViewControllerTests.swift
//  Snappy
//
//  Created by Pawel Chmiel on 07.06.2017.
//  Copyright © 2017 Droids on Roids. All rights reserved.
//

import XCTest
import OHHTTPStubs

@testable import Snappy

class MockSnapViewController: SnapViewController {
    var expectation: XCTestExpectation?
    
    override func timerAction() {
        super.timerAction()
        expectation?.fulfill()
    }
}

class SnapViewControllerTests: XCTestCase {
    
    var viewController: MockSnapViewController!

    override func setUp() {
        super.setUp()
        
        viewController = MockSnapViewController(snap: Snap(url: "http://google.pl", fileName: ""))
    }

    func testSnapRemoveImage() {
        
        _ = viewController.view
        
        let exp = expectation(description: "")
        
        UIGraphicsBeginImageContext(CGSize(width: 100, height: 100))
        UIColor.red.setFill()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        OHHTTPStubs.stubRequests(passingTest: { (request) -> Bool in
            return true
        }) { (request) -> OHHTTPStubsResponse in
            let data = image!.data
            return OHHTTPStubsResponse(data: data!, statusCode: 200, headers: nil)
        }
        
        viewController.expectation = exp
        viewController.downloadImage()
        
        wait(for: [exp], timeout: 11.0)
    }
}
