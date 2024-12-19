//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Kaushik on 03/09/2024.
//

import XCTest
import EssentialFeed

typealias FailableFeedStore = FeedStoreSpecs & FailableRetrieveFeedStoreSpecs & FailableInsertFeedStoreSpecs & FailableDeleteFeedStoreSpecs

final class CodableFeedStoreTests: XCTestCase, FailableFeedStore {

    override func setUp() {
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        undoStoreSideEffects()
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        expect(sut, toRetrieve: .success(.empty))
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        expect(sut, toRetrieveTwice: .success(.empty))
    }
    
    func test_retrieve_deliversFoundValueOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = UniqueImageFeed().localItems
        let timeStamp = Date()
        
        insert((feed,timeStamp), to: sut)
        
        expect(sut, toRetrieve: .success(.found(feed: feed, timestamp: timeStamp)))
    }

    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = UniqueImageFeed().localItems
        let timeStamp = Date()
        
        insert((feed,timeStamp), to: sut)
        
        expect(sut, toRetrieveTwice: .success(.found(feed: feed, timestamp: timeStamp)))
    }
    
    func test_retrieve_deliversErrorOnRetrievalError() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL:storeURL)

        try! "invalid json".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrieve: .failure(anyNSError()))
    }
    func test_retrieve_hasNoSideEffectsOnFailure() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL:storeURL)

        try! "invalid json".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrieveTwice: .failure(anyNSError()))
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        let firstInsertionError = insert((UniqueImageFeed().localItems,Date()), to: sut)
        XCTAssertNil(firstInsertionError,"expected no error on first insertion")
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        insert((UniqueImageFeed().localItems,Date()), to: sut)
        let latestFeed = UniqueImageFeed().localItems
        let date = Date()
        let secondIntertionError = insert((latestFeed,date), to: sut)
        XCTAssertNil(secondIntertionError,"expected no error for inserting to non empty cache")
    }
    
    func test_insert_overridesPreviouslyInsertedCache() {
        let sut = makeSUT()
        insert((UniqueImageFeed().localItems,Date()), to: sut)
        let latestFeed = UniqueImageFeed().localItems
        let date = Date()
        insert((latestFeed,date), to: sut)
        expect(sut, toRetrieve: .success(.found(feed: latestFeed, timestamp: date)))
    }
    
    func test_insert_deliversErrorOnInsertionError() {
        let invalidURL = URL(string: "invalidurl")
        let sut = makeSUT(storeURL: invalidURL)
        let insertionError = insert((UniqueImageFeed().localItems,Date()), to: sut)
        XCTAssertNotNil(insertionError,"Expected to return error for invalid url")
    }
    
    func test_insert_hasNoSideEffectsOnInsertionError() {
        let invalidURL = URL(string: "invalidurl")
        let sut = makeSUT(storeURL: invalidURL)
        insert((UniqueImageFeed().localItems,Date()), to: sut)
        expect(sut, toRetrieve: .success(.empty))
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError,"Expected deletion error to be nil")
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        deleteCache(from: sut)
        expect(sut, toRetrieve: .success(.empty))
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        insert((UniqueImageFeed().localItems,Date()), to: sut)
        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError,"Expected deletion error to be nil")
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        insert((UniqueImageFeed().localItems,Date()), to: sut)
        deleteCache(from: sut)
        expect(sut, toRetrieve: .success(.empty))
    }
    
    func test_delete_returnsDeletionError() {
        let noPermissonURL = cachesDirectory()
        let sut = makeSUT(storeURL: noPermissonURL)
        let deletionError = deleteCache(from: sut)
        XCTAssertNotNil(deletionError,"Expected to return error on invalid url")
    }
    
    func test_delete_hasNoSideEffectsOnDeletionError() {
        let noPermissonURL = cachesDirectory()
        let sut = makeSUT(storeURL: noPermissonURL)
        deleteCache(from: sut)
        expect(sut, toRetrieve: .success(.empty))
    }
    
    func test_sideEffects_runSerially() {
        let sut = makeSUT()
        var completedOperationsInOrder = [XCTestExpectation]()
        let operation1 = expectation(description: "operation 1")
        sut.insert((UniqueImageFeed().localItems,Date())) { _ in
            completedOperationsInOrder.append(operation1)
            operation1.fulfill()
        }
        let operation2 = expectation(description: "operation 2")
        sut.insert((UniqueImageFeed().localItems,Date())) { _ in
            completedOperationsInOrder.append(operation2)
            operation2.fulfill()
        }
        let operation3 = expectation(description: "operation 3")
        sut.retrieve { _ in
            completedOperationsInOrder.append(operation3)
            operation3.fulfill()
        }
        waitForExpectations(timeout: 5.0)
        XCTAssertEqual(completedOperationsInOrder, [operation1,operation2,operation3],"Expected operations to run serially but failed")

    }

    //MARK: - HELPERS
    private func makeSUT(storeURL:URL? = nil, file: StaticString = #filePath,
                         line: UInt = #line) -> CodableFeedStore {
        let url = testSpecificStoreURL()
        let sut = CodableFeedStore(storeURL: storeURL ?? url)
        trackForMemoryLeaks(sut,file: file, line: line)
        return sut
    }
    
    private func testSpecificStoreURL() -> URL {
        return cachesDirectory().appendingPathExtension("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    
}
