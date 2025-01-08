//
//  CacheFeedImageDataUseCaseTests.swift
//  EssentialFeed
//
//  Created by Kouv on 05/01/2025.
//

import XCTest
import EssentialFeed

class CacheFeedImageDataUseCaseTests:XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_,store) = makesut()
        XCTAssertTrue(store.receivedMessages.isEmpty,"Expected messages to be empty on init")
    }
    
    
    func test_saveImageData_requestsImageDataInsertionForURL() {
        let (sut,store) = makesut()
        let newImageData = anyData()
        let url = anyURL()
        sut.saveImageData(newImageData, for: url) { _ in
            
        }
        XCTAssertEqual(store.receivedMessages, [.insert(data: newImageData, url: url)])
    }
    
    func test_saveImageDataForURL_deliversErrorOnClientError() {
        let (sut,store) = makesut()
        expect(sut, toCompleteWith: failed()) {
            let saveError = anyNSError()
            store.completeInsertion(with: saveError)
        }
    }
    
    func test_saveImageDataForURL_successfullyInsertsImageData() {
        let (sut,store) = makesut()
        expect(sut, toCompleteWith: .success(())) {
            store.completeInsertionSuccessfully()
        }
    }
    
    func test_saveImageDataForURL_doesNotDeliverAfterInstanceHasbeenDeallocated() {
        let store = FeedImageDataStoreSpy()
        var sut:LocalFeedImageDataLoader? = LocalFeedImageDataLoader(store: store)
        let url = anyURL()
        let newImageData = anyData()
        var receivedResult = [LocalFeedImageDataLoader.SaveResult]()
        sut?.saveImageData(newImageData, for: url){  receivedResult.append($0)
        }
        sut = nil
        store.completeInsertionSuccessfully()
        XCTAssertTrue(receivedResult.isEmpty,"Expected no result after sut is deallocated")
        
    }
        
    
    //MARK: - helpers
    private func makesut(file: StaticString = #filePath,
                         line: UInt = #line) -> (sut:LocalFeedImageDataLoader,store:FeedImageDataStoreSpy) {
        let store = FeedImageDataStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(store,file: file,line: line)
        trackForMemoryLeaks(sut,file: file,line: line)
        return(sut,store)
    }
    
    private func failed() -> LocalFeedImageDataLoader.SaveResult {
        return .failure(LocalFeedImageDataLoader.SaveError.failed)
    }
    
    private func expect(_ sut:LocalFeedImageDataLoader, toCompleteWith expectedResult:LocalFeedImageDataLoader.SaveResult,when action:()->Void,file: StaticString = #filePath,
                        line: UInt = #line) {
        let url = anyURL()
        let insertImageData = anyData()

        let exp = expectation(description: "wait for load image data")
        sut.saveImageData(insertImageData, for: url){receivedResult in
            switch (receivedResult,expectedResult) {
            case (.success,.success):
                break
            case let (.failure(receivedError as NSError),.failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError,file: file,line: line)
            default:
                XCTFail("expected result \(expectedResult) but got result \(receivedResult) instead")
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
    }
}
