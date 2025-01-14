//
//  CoreDataFeedImageDataStoreTests.swift
//  EssentialFeed
//
//  Created by Kouv on 05/01/2025.
//

import XCTest
import EssentialFeed


final class CoreDataFeedImageDataStoreTests : XCTestCase {
    func test_retrieveImageData_deliversNotFoundWhenEmpty() {
        let sut = makeSUT()
        expect(sut, toCompleteRetrievalWith: .success(.none),for: anyURL())
    }
    
    func test_retrieveImageData_deliversNotFoundWhenURLDoesNotMatch() {
        let sut = makeSUT()
        let insertURL = anyURL()
        insert(anyData(), for: insertURL, into: sut)
        let retrieveURL = URL(string: "https://any-url.com")!
        expect(sut, toCompleteRetrievalWith: .success(.none),for: retrieveURL)
    }
    
    func test_retrieveImageData_deliversFoundDataWhenThereIsAStoredImageDataMatchingURL() {
            let sut = makeSUT()
            let storedData = anyData()
            let matchingURL = URL(string: "http://a-url.com")!

            insert(storedData, for: matchingURL, into: sut)

        expect(sut, toCompleteRetrievalWith: .success(storedData), for: matchingURL)
        }
    
    func test_retrieveImageData_deliversLastInsertedValue() {
        let sut = makeSUT()
        let firstData = Data("first".utf8)
        let lastData = Data("last".utf8)
        let storeURL = URL(string: "http://a-url.com")!

        
        insert(firstData, for: storeURL, into: sut)
        insert(lastData, for: storeURL, into: sut)
        
        expect(sut, toCompleteRetrievalWith: .success(lastData), for: storeURL)

    }
    
    func test_sideEffects_runsSerially() {
        let sut = makeSUT()
        let url = anyURL()
        
        let op1 = expectation(description: "wait for operation 1")
        sut.insert([localImage(url: anyURL())], timestamp: Date()) { _ in
            op1.fulfill()
        }
        
        let op2 = expectation(description: "wait for operation 2")
        sut.insert(anyData(), for: url) { _ in
            op2.fulfill()
        }
        
        let op3 = expectation(description: "wait for operation 3")
        sut.insert(anyData(), for: url) { _ in
            op3.fulfill()
        }
        
        wait(for: [op1,op2,op3], timeout: 5.0, enforceOrder: true)
    }
    
    //MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath,
                         line: UInt = #line) -> CoreDataFeedStore {
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL)
        trackForMemoryLeaks(sut,file: file,line: line)
        return sut
    }
 
    private func expect(_ sut:CoreDataFeedStore,toCompleteRetrievalWith expectedResult:FeedImageDataStore.RetrievalResult, for url:URL,file: StaticString = #filePath,
                        line: UInt = #line) {
        let exp = expectation(description: "wait to retrieve images")
        sut.retrieve(dataForURL:url){ receivedResult in
            switch (receivedResult,expectedResult) {
            case let (.success(receivedData),.success(expectedData)):
                XCTAssertEqual(receivedData, expectedData,file: file,line: line)
               
            default:
                XCTFail("should have received \(expectedResult) but instead received \(receivedResult)")
            }
            exp.fulfill()
        }
        wait(for: [exp],timeout: 1.0)
    }
    
    
    private func localImage(url: URL) -> LocalFeedImage {
            return LocalFeedImage(id: UUID(), description: "any", location: "any", url: url)
        }
    
    private func insert(_ data: Data, for url: URL, into sut: CoreDataFeedStore, file: StaticString = #file, line: UInt = #line) {
            let exp = expectation(description: "Wait for cache insertion")
            let image = localImage(url: url)
            sut.insert([image], timestamp: Date()) { result in
                switch result {
                case let .failure(error):
                    XCTFail("Failed to save \(image) with error \(error)", file: file, line: line)
                    exp.fulfill()
                case .success:
                    sut.insert(data, for: url) { result in
                        if case let Result.failure(error) = result {
                            XCTFail("Failed to insert \(data) with error \(error)", file: file, line: line)
                        }
                        exp.fulfill()

                    }
                }
            }
            wait(for: [exp], timeout: 1.0)
        }
    
}
