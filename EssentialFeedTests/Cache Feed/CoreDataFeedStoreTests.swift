//
//  CoreDataFeedStoreTests.swift
//  EssentialFeed
//
//  Created by Kouv on 05/01/2025.
//

import XCTest
import EssentialFeed

final class CoreDataFeedStoreTests : XCTestCase,  FeedStoreSpecs{
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makesut()
        assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makesut()
        assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
    }
    
    func test_retrieve_deliversFoundValueOnNonEmptyCache() {
        let sut = makesut()
        assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makesut()
        assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makesut()
        assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        let sut = makesut()
        assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
    }
    
    func test_insert_overridesPreviouslyInsertedCache() {
        let sut = makesut()
        assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() {
        let sut = makesut()
        assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makesut()
        assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache() {
        let sut = makesut()
        assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makesut()
        assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
    }
    
    func test_sideEffects_runSerially() {
        let sut = makesut()
        assertThatSideEffectsRunSerially(on: sut)
    }
    
    
    //MARK: - Helpers
    
    private func makesut() -> CoreDataFeedStore {
        let url = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: url)
        trackForMemoryLeaks(sut)
        return sut
    }
    
}
