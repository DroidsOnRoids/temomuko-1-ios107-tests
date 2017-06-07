//
//  PreviewViewControllerTests.swift
//  Snappy
//
//  Created by Pawel Chmiel on 07.06.2017.
//  Copyright © 2017 Droids on Roids. All rights reserved.
//

import Foundation
import XCTest
import OHHTTPStubs
@testable import Snappy

class MockPreviewViewController: PreviewViewController {
    var expectation: XCTestExpectation?
    
    override var imageSaved: Bool {
        willSet(newValue){
            expectation?.fulfill()
            XCTAssertTrue(newValue)
        }
    }
}

class previewTest: XCTestCase {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    var viewController: PreviewViewController?
    var image: UIImage?
    
    override func setUp() {
        super.setUp()
        
        UIGraphicsBeginImageContext(CGSize(width: 100, height: 100))
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        viewController = storyboard.instantiateViewController(withIdentifier: "preview") as? PreviewViewController
        viewController?.image = image
        
        _ = viewController!.view
        
    }
    
    override func tearDown() {
        super.tearDown()
        image = nil
        viewController = nil
    }
    
    func testPreviewImageExist() {
        XCTAssertEqual(image, viewController?.previewImageView.image)
    }
    
    func testFilteredImage() {
        viewController!.setFilteredImage()
        
        XCTAssertNotEqual(image,viewController!.filteredImage)
    }
    
    func testFilteredImageWhenFilteredImageExists() {
        viewController?.filteredImage = image
        XCTAssertEqual(image, viewController?.filteredImage)
    }
    
    func testSegmentedControll() {
        viewController!.segmentedControl.selectedSegmentIndex = 0
        viewController?.segmentedControlAction(viewController!.segmentedControl)
        XCTAssertEqual(viewController!.previewImageView.image, image!)
        viewController!.segmentedControl.selectedSegmentIndex = 1
        viewController?.segmentedControlAction(viewController!.segmentedControl)
        XCTAssertEqual(viewController!.previewImageView.image, viewController!.filteredImage)
    }
    
    
    //ACTIONS
    func testCloseButtonAction() {
        viewController?.closeButtonAction(UIButton())
        XCTAssertFalse(viewController!.isBeingDismissed)
    }
    
    func testSaveButtonAction() {
        //MOZE SIE WYWALIC BO NIE MA DOSTEPU DO ZAPISYWANIA
        let exp = expectation(description: "save image")
        let vc = MockPreviewViewController()
        vc.image = image
        vc.previewImageView = viewController?.previewImageView
        _ = vc.view
        
        vc.expectation = exp
        
        vc.saveButtonAction(UIButton())
        wait(for: [exp], timeout: 5.0)
    }
    
    func testSendButtonAction() {
        //GIVEN
        let exp = expectation(description: "upload image")
        
        OHHTTPStubs.stubRequests(passingTest: { _ in
            return true
        }) { _ in
            let data = "{\"Success\": \"Image uploaded correctly.\"}".data(using: .utf8)!
            return OHHTTPStubsResponse(data: data, statusCode: 200, headers: nil)
        }
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        button.isEnabled = true
        
        //WHEN
        viewController?.sendButtonAction(button)
        
        //THEN
        XCTAssertFalse(button.isEnabled)
        XCTAssertTrue(UIApplication.shared.isNetworkActivityIndicatorVisible)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            print("fulfilll")
            exp.fulfill()
            XCTAssertTrue(button.isEnabled)
            XCTAssertFalse(UIApplication.shared.isNetworkActivityIndicatorVisible)
        }

        wait(for: [exp], timeout: 5.0)
    }
}
