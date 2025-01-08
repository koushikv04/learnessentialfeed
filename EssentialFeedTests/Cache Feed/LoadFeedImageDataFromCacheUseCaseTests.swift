//
//  LocalFeedImageDataLoaderTests.swift
//  EssentialFeed
//
//  Created by Kouv on 04/01/2025.
//
import XCTest
import EssentialFeed

final class LoadFeedImageDataFromCacheUseCaseTests:XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (_,store) = makesut()
        XCTAssertTrue(store.receivedMessages.isEmpty,"Expected messages to be empty on init")
    }
    
    func test_loadImageData_requestsStoredDataForURL() {
        let (sut,store) = makesut()
        let url = anyURL()
        _ = sut.loadImageData(url:url){_ in }
        
        XCTAssertEqual(store.receivedMessages, [.retrieve(dataFor: url)])
    }
    
    func test_loadImageData_failsOnStoreError() {
        let (sut,store) = makesut()
        let retrievalError = anyNSError()
        expect(sut, toCompleteWith: failed()) {
            store.completeRetrieval(with: retrievalError)
        }
    }
    
    func test_loadImageData_failsOnNotFoundError() {
        let (sut,store) = makesut()
        expect(sut, toCompleteWith: notFound()) {
            store.completeRetrieval(with:.none)
        }
    }
    
    func test_loadImageData_deliversStoredDataForGivenURL() {
        let (sut,store) = makesut()
        let foundData = anyData()
        expect(sut, toCompleteWith: .success(foundData)) {
            store.completeRetrieval(with:foundData)
        }
    }
    
    func test_loadImageDataFromURL_doesNotDeliverImageAfterCancellingTask() {
        let (sut,store) = makesut()
        let url = anyURL()
        var receivedResult = [FeedImageLoader.Result]()
        let task = sut.loadImageData(url: url) { receivedResult.append($0)
        }
        task.cancel()
        store.completeRetrieval(with: anyNSError())
        store.completeRetrieval(with:anyData())
        store.completeRetrieval(with:.none)
        XCTAssertTrue(receivedResult.isEmpty)
    }
    
    func test_loadImageDataFromURL_doesNotDeliverAfterInstanceHasbeenDeallocated() {
        let store = FeedImageDataStoreSpy()
        var sut:LocalFeedImageDataLoader? = LocalFeedImageDataLoader(store: store)
        let url = anyURL()
        var receivedResult = [FeedImageLoader.Result]()
        _ = sut?.loadImageData(url: url, completion: { receivedResult.append($0)
        })
        sut = nil
        store.completeRetrieval(with:anyData())
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
    
    private func failed() -> FeedImageLoader.Result {
        return .failure(LocalFeedImageDataLoader.LoadError.failed)
    }
    
    private func notFound() -> FeedImageLoader.Result {
        return .failure(LocalFeedImageDataLoader.LoadError.notFound)
    }
    
    private func expect(_ sut:LocalFeedImageDataLoader, toCompleteWith expectedResult:FeedImageLoader.Result,when action:()->Void,file: StaticString = #filePath,
                        line: UInt = #line) {
        let url = anyURL()

        let exp = expectation(description: "wait for load image data")
        _ = sut.loadImageData(url:url){receivedResult in
            switch (receivedResult,expectedResult) {
            case let (.success(receivedData),.success(expectedData)):
                XCTAssertEqual(receivedData, expectedData,file: file, line: line)
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
