//
//  ValidateCacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Kaushik on 27/08/2024.
//

import XCTest
import EssentialFeed

final class ValidateCacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let (feedStore,_) = makeSUT()
        XCTAssertEqual(feedStore.receivedMessages, [])
    }
    
    func test_validateCache_deletesCacheFeedOnRetrievalError() {
        let(store,sut) = makeSUT()
        sut.validateCache(){_ in }
        store.completeRetrieval(with: anyNSError())
        XCTAssertEqual(store.receivedMessages, [.retrieve,.deleteCacheFeed])
    }
    
    func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
        let(store,sut) = makeSUT()
        sut.validateCache(){_ in }
        store.completeRetrievalWithEmptyCache()
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_validateCache_doesNotDeleteOnNonExpiredCache() {
        let(store,sut) = makeSUT()
        let fixedCurrentDate = Date()
        let nonExpiredTimeStamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds:1)
        sut.validateCache(){_ in }
        store.completeRetrieval(with: uniqueImageFeed().local, timeStamp: nonExpiredTimeStamp)
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_validateCache_deletesCacheOnExpiration() {
        let(store,sut) = makeSUT()
        let fixedCurrentDate = Date()
        let expirationTimeStamp = fixedCurrentDate.minusFeedCacheMaxAge()
        sut.validateCache(){_ in }
        store.completeRetrieval(with: uniqueImageFeed().local, timeStamp: expirationTimeStamp)
        XCTAssertEqual(store.receivedMessages, [.retrieve,.deleteCacheFeed])
    }
    
    func test_validateCache_deletesExpiredCache() {
        let(store,sut) = makeSUT()
        let fixedCurrentDate = Date()
        let expiredTimeStamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        sut.validateCache(){_ in }
        store.completeRetrieval(with: uniqueImageFeed().local, timeStamp: expiredTimeStamp)
        XCTAssertEqual(store.receivedMessages, [.retrieve,.deleteCacheFeed])
    }
    
    func test_validateCache_doesNotDeleteInvalidCacheAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut:LocalFeedLoader? = LocalFeedLoader(feedStore: store, currentDate: Date.init)
        
        sut?.validateCache(){_ in }
        
        sut = nil
        store.completeRetrieval(with: anyNSError())
        XCTAssertEqual(store.receivedMessages, [.retrieve])
        
    }
    
    func test_validateCache_failsOnDeletionErrorOfFailedRetrival() {
        let (store,sut) = makeSUT()
        let deletionError = anyNSError()
        
        expect(sut,toCompleteWith: .failure(deletionError), when : {
            store.completeRetrieval(with: anyNSError())
            store.completeDeletion(with:deletionError)
        })
    }
    
    func test_validateCache_succeedsOnSuccessfulDeletionOfFailedRetrieval() {
        let (store,sut) = makeSUT()

        expect(sut, toCompleteWith: .success(()), when: {
            store.completeRetrieval(with: anyNSError())
            store.completeDeletionSuccessfully()
        })
    }
    
    func test_validateCache_succeedsOnEmptyCache() {
        let (store,sut) = makeSUT()
        
        expect(sut, toCompleteWith: .success(()), when: {
            store.completeRetrievalWithEmptyCache()
        })
    }
    
    func test_validateCache_succeedsOnNonExpiredCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        let (store,sut) = makeSUT(currentDate: {fixedCurrentDate})
        
        expect(sut, toCompleteWith: .success(())) {
            store.completeRetrieval(with: feed.local,timeStamp:nonExpiredTimestamp)
        }
    }
    
    func test_validateCache_failsOnDeletionErorOfExpiredCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let (store,sut) = makeSUT(currentDate: {fixedCurrentDate})
        let deletionError = anyNSError()
        
        expect(sut, toCompleteWith: .failure(deletionError)) {
            store.completeRetrieval(with: feed.local,timeStamp: expiredTimestamp)
            store.completeDeletion(with: deletionError)
        }
    }
    
    func test_validateCache_succeeddsOnSuccessfulDeletionOfExpiredCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let (store,sut) = makeSUT(currentDate: {fixedCurrentDate})
        
        expect(sut, toCompleteWith: .success(())) {
            store.completeRetrieval(with: feed.local,timeStamp: expiredTimestamp)
            store.completeDeletionSuccessfully()
        }
    }
    
    
    
    
    //MARK: - HELPERS
    
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedResult: LocalFeedLoader.ValidationResult, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.validateCache { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.success, .success):
                break
                
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
    }

    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init,file: StaticString = #filePath,
                         line: UInt = #line) -> (store:FeedStoreSpy,sut:LocalFeedLoader) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(feedStore: store, currentDate:currentDate)
        trackForMemoryLeaks(store,file: file,line: line)
        trackForMemoryLeaks(sut,file: file,line: line)
        return (store,sut)
    }
}
