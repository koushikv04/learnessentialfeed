//
//  XCTTestCase+MemoryLeakTracking.swift
//  EssentialFeedTests
//
//  Created by Kaushik on 30/07/2024.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ instance:AnyObject,file: StaticString = #filePath,
                                     line: UInt = #line) {
        addTeardownBlock {[weak instance] in
            XCTAssertNil(instance,"should have been deallocated but possible memory leak",file: file,line: line)
        }
    }
}
