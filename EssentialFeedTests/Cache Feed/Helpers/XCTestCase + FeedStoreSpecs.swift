//
//  XCTestCase + FeedStoreSpecs.swift
//  EssentialFeed
//
//  Created by Kaushik on 09/12/2024.
//
import XCTest
import EssentialFeed

extension FeedStoreSpecs where Self: XCTestCase {
    @discardableResult
    func insert(_ cache:(feed:[LocalFeedImage],timestamp:Date),to sut:FeedStore) -> Error? {
        var receivedError:Error?
        let exp = expectation(description: "wait for cache insertion")
        sut.insert((cache.feed, timestamp: cache.timestamp)) { error in
            receivedError = error
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return receivedError
    }
    
    @discardableResult
    func deleteCache(from sut:FeedStore) -> Error? {
        let exp = expectation(description: "wait for cache deletion")

        var deletionError:Error?
        sut.deleteCachedFeed { error in
            deletionError = error
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return deletionError
    }
    
    func expect(_ sut:FeedStore,toRetrieveTwice expectedResult:FeedStore.RetrievalResult,file: StaticString = #filePath,
                        line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult,file: file,line: line)
        expect(sut, toRetrieve: expectedResult,file: file,line: line)
    }
    
    func expect(_ sut:FeedStore,toRetrieve expectedResult:FeedStore.RetrievalResult,file: StaticString = #filePath,
                        line: UInt = #line) {
        let exp = expectation(description: "wait for retrieve completion")
        sut.retrieve { retrieveResult in
            switch (expectedResult,retrieveResult) {
            case (.success,.success),(.failure,.failure):
                break
            case let (.success(.found(expected)),.success(.found(retrieved))):
                XCTAssertEqual(expected.feed, retrieved.feed,file: file, line: line)
                XCTAssertEqual(expected.timestamp, retrieved.timestamp,file: file, line: line)
            default:
                XCTFail("expected to retrieve \(expectedResult) but got result \(retrieveResult)",file: file,line: line)
            }
            exp.fulfill()
        }
           
        wait(for: [exp], timeout: 1.0)
    }
}
