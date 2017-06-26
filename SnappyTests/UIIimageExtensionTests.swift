//
//  SnappyTests.swift
//  SnappyTests
//
//  Created by Pawel Chmiel on 02.06.2017.
//  Copyright © 2017 Droids on Roids. All rights reserved.
//

import XCTest
@testable import Snappy

class UIImageExtensionTests: XCTestCase {
    
    var createdImage: UIImage {
        UIGraphicsBeginImageContext(CGSize(width: 100, height: 100))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    func testResizedImage() {
        let newImage = createdImage.resized(newSize: CGSize(width: 50, height: 100))
        
        XCTAssertNotEqual(createdImage.size.width, newImage.size.width)
        XCTAssertEqual(50, newImage.size.width)
        XCTAssertEqual(100, newImage.size.height)
    }
    
    func testFixImageOrientation() {
        let startImage = UIImage(cgImage: createdImage.cgImage!, scale: 1.0, orientation: .down)
        
        let newImage = startImage.fixImageOrientation()
        
        XCTAssertEqual(newImage.imageOrientation, .up)
    }
}
