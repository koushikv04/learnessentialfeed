//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Kaushik on 06/08/2024.
//

import XCTest
import EssentialFeed

enum Result {
    case success
    case failure(Error)
}



final class CacheFeedUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (feedStore,_) = makeSUT()
        XCTAssertEqual(feedStore.receivedMessages, [])
    }
    
    func test_save_requestCacheDeletion() {
        let (store,sut) = makeSUT()
        sut.save( UniqueImageFeed().models) { _ in}
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
    }
    
    
    func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let (store,sut) = makeSUT(currentDate: {timestamp})
        let (items,localItems) = UniqueImageFeed()
        sut.save( items ) { _ in}
        store.completeDeletionSuccessfully()
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed,.insert(localItems, timestamp)])
        
    }
    
    func test_save_failsDuetoDeletionError() {
        let (store,sut) = makeSUT()
        let deletionError = anyNSError()
        expect(sut, toCompleteWithError: deletionError) {
            store.completeDeletion(with: deletionError)
        }
    }
    
    func test_save_failsDuetoInsertionError() {
        let (store,sut) = makeSUT()
        let insertionError = anyNSError()
        expect(sut, toCompleteWithError: insertionError) {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: insertionError)
        }
    }
    
    func test_save_succeedsWithSuccessfulCacheInsertion() {
        let (store,sut) = makeSUT()
        expect(sut, toCompleteWithError: nil) {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        }
    }
    
    func test_save_doesNotDeliverDeletionErrorAfterSUIInstancehasbeenDellocated() {
        let store = FeedStoreSpy()
        var sut:LocalFeedLoader? = LocalFeedLoader(feedStore: store, currentDate: Date.init)
        var receivedResults = [LocalFeedLoader.SaveResult]()
        sut?.save(UniqueImageFeed().models, completion: { error in
            receivedResults.append(error)
        })
        sut = nil
        store.completeDeletion(with: anyNSError())
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    func test_save_doesNotDeliverInsertionErrorAfterSUIInstancehasbeenDellocated() {
        let store = FeedStoreSpy()
        var sut:LocalFeedLoader? = LocalFeedLoader(feedStore: store, currentDate: Date.init)
        var receivedResults = [LocalFeedLoader.SaveResult]()
        sut?.save( UniqueImageFeed().models, completion: { error in
            receivedResults.append(error)
        })
        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertion(with: anyNSError())
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
    
    private func expect(_ sut:LocalFeedLoader,toCompleteWithError expectedError:NSError?,when action: ()-> Void,file: StaticString = #filePath,
                        line: UInt = #line) {
        var receivedError:Error?
        let exp = self.expectation(description: "wait for save to finish")
        sut.save(UniqueImageFeed().models) { error in
            receivedError = error
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedError as? NSError,expectedError)
    }
    
   
}
