//
//  SnapViewControllerTests.swift
//  Snappy
//
//  Created by Pawel Chmiel on 02.06.2017.
//  Copyright © 2017 Droids on Roids. All rights reserved.
//

import XCTest
import OHHTTPStubs

@testable import Snappy

class APITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        OHHTTPStubs.stubRequests(passingTest: { _ -> Bool in
            return true
        }) { request -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse.init(fileAtPath: OHPathForFile("sample.json", APITests.classForCoder())!, statusCode: 200, headers: nil)
        }
    }
    
    func testCreateSnapFromJsonFile() {
        let exp = expectation(description: "")
        let endpoint = Endpoint.getPhotos(userId: nil)
        var snaps = [Snap]()
        API.request(endpoint) { success, valueDictionary in
            guard let images = valueDictionary?["images"] as? [[String: Any]] else { return }
            
            
            images.forEach { image in
                guard let url = image["url"] as? String, let fileName = image["file_name"] as? String else { return }
                
                let snap = Snap(url: url, fileName: fileName)
                snaps.append(snap)
            }
            exp.fulfill()
            XCTAssertTrue(snaps.count == 4)
            
        }
        wait(for: [exp], timeout: 2.0)
    }
}
