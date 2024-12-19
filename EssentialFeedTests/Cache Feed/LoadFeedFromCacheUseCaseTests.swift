//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Kaushik on 23/08/2024.
//

import XCTest
import EssentialFeed

final class LoadFeedFromCacheUseCaseTests: XCTestCase {
    func test_init_doesNotDeleteCacheUponCreation() {
        let (feedStore,_) = makeSUT()
        XCTAssertEqual(feedStore.receivedMessages, [])
    }
    
    func test_load_requestCacheRetrieve() {
        let (feedStore,sut) = makeSUT()
        sut.load() { _ in}
        XCTAssertEqual(feedStore.receivedMessages, [.retrieve])
    }
    
    func test_load_failsOnRetrievalError() {
        let (feedStore,sut) = makeSUT()
        let retrievalError = anyNSError()
        expect(sut, toCompleteWith: .failure(retrievalError)) {
            feedStore.completeRetrieval(with:retrievalError)
        }
    }
    func test_load_deliversNoImageOnEmptyCache() {
        let (feedStore,sut) = makeSUT()
        expect(sut, toCompleteWith: .success([])) {
            feedStore.completeRetrievalWithEmptyCache()
        }
    }
    
    func test_load_deliversCacheImagesOnNonExpiredCache() {
        let fixedCurrentDate = Date()
        let nonExpiredTimeStamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds:1)
        let (feedStore,sut) = makeSUT(currentDate: {fixedCurrentDate})
        let feed = UniqueImageFeed()
        expect(sut, toCompleteWith: .success(feed.models)) {
            feedStore.completeRetrieval(with:feed.localItems, timeStamp:nonExpiredTimeStamp)
        }
    }
    
    func test_load_deliversNoCachedImagesOnCacheExpiration() {
        let fixedCurrentDate = Date()
        let expirationTimeStamp = fixedCurrentDate.minusFeedCacheMaxAge()
        let (feedStore,sut) = makeSUT(currentDate: {fixedCurrentDate})
        let feed = UniqueImageFeed()
        expect(sut, toCompleteWith: .success([])) {
            feedStore.completeRetrieval(with:feed.localItems, timeStamp:expirationTimeStamp)
        }
    }
    
    func test_load_deliversNoCachedImagesOnExpiredCache() {
        let fixedCurrentDate = Date()
        let expiredTimeStamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let (feedStore,sut) = makeSUT(currentDate: {fixedCurrentDate})
        let feed = UniqueImageFeed()
        expect(sut, toCompleteWith: .success([])) {
            feedStore.completeRetrieval(with:feed.localItems, timeStamp:expiredTimeStamp)
        }
    }
    
    func test_load_hasNoSideEffectsOnRetrievalError() {
        let(store,sut) = makeSUT()
        sut.load { _ in
            
        }
        store.completeRetrieval(with: anyNSError())
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsOnEmptyCache() {
        let(store,sut) = makeSUT()
        sut.load { _ in
            
        }
        store.completeRetrievalWithEmptyCache()
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsOnNonExpiredCache() {
        let(store,sut) = makeSUT()
        let fixedCurrentDate = Date()
        let nonExpiredTimeStamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds:1)
        sut.load { _ in
            
        }
        store.completeRetrieval(with: UniqueImageFeed().localItems, timeStamp: nonExpiredTimeStamp)
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsOnCacheExpiration() {
        let(store,sut) = makeSUT()
        let fixedCurrentDate = Date()
        let expirationTimeStamp = fixedCurrentDate.minusFeedCacheMaxAge()
        sut.load { _ in
            
        }
        store.completeRetrieval(with: UniqueImageFeed().localItems, timeStamp: expirationTimeStamp)
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsOnExpiredCache() {
        let(store,sut) = makeSUT()
        let fixedCurrentDate = Date()
        let expiredTimeStamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        sut.load { _ in
            
        }
        store.completeRetrieval(with: UniqueImageFeed().localItems, timeStamp: expiredTimeStamp)
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_doesNotDeliverAfterLoaderHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut:LocalFeedLoader? = LocalFeedLoader(feedStore: store, currentDate: Date.init)
        var receivedResults = [LocalFeedLoader.LoadResult]()
        sut?.load() { result in
            receivedResults.append(result)
        }
        sut = nil
        store.completeRetrieval(with: anyNSError())
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    //MARK: - HELPERS
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init,file: StaticString = #filePath,
                         line: UInt = #line) -> (store:FeedStoreSpy,sut:LocalFeedLoader) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(feedStore: store, currentDate:currentDate)
        trackForMemoryLeaks(store,file: file,line: line)
        trackForMemoryLeaks(sut,file: file,line: line)
        return (store,sut)
    }
    
    
    private func expect(_ sut:LocalFeedLoader,toCompleteWith expectedResult:LocalFeedLoader.LoadResult, when action:()->Void,file: StaticString = #filePath,
                        line: UInt = #line) {
        let exp = self.expectation(description: "wait for load completion")
        sut.load() { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedImages),.success(expectedImages)):
                XCTAssertEqual(receivedImages, expectedImages,file: file,line:line)
            case let (.failure(receivedError),.failure(expectedError)):
                XCTAssertEqual(receivedError as NSError, expectedError as NSError,file:file,line:line)
            default:
                XCTFail("Expected Result \(expectedResult) instead Received Result \(receivedResult)",file:file,line:line)
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
    }

    
}


