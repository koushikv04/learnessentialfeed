//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeed
//
//  Created by Kouv on 03/01/2025.
//

import XCTest
import EssentialFeed

final class LoadFeedImageFromRemoteUseCaseTests:XCTestCase {
    func test_init_doesNotLoadImage() {
        let (_,client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
        
    }
    
    func test_loadImage_requestsDataFromURL() {
        let url =  URL(string:"http\\any-url")!
        let (sut,client) = makeSUT()

        
        _ = sut.loadImageData(url:url){_ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadImage_callsFuctionTwice() {
        let url =  URL(string:"http\\any-url")!
        let (sut,client) = makeSUT()

        
        _ = sut.loadImageData(url:url){_ in }
        _ = sut.loadImageData(url:url){_ in }
        
        XCTAssertEqual(client.requestedURLs, [url,url])
    }
    
    func test_loadImage_deliversErrorOnClientError() {
        let (sut,client) = makeSUT()
        let clientError = anyNSError()
        expect(sut, toCompleteWith: failure(error: .connectivity), when: {
            client.completeWith(.failure(clientError))
        })
    }
    
    func test_loadImage_deliversErrorOnInvalidDataOnNon200HTTPResponse() {
        let (sut,client) = makeSUT()
        let samples = [199,201,300,400,500]
        samples.enumerated().forEach{index,code in
            expect(sut, toCompleteWith: .failure(RemoteFeedImageDataLoader.Error.invalidData), when: {
                client.completeWith(code: code, data: anyData(),at: index)
            })
        }
        
    }
    
    func test_loadImage_deliversInvalidDataOn200HTTPResponseWithEmptyData() {
        let (sut,client) = makeSUT()
        expect(sut, toCompleteWith: failure(error: .invalidData), when: {
            client.completeWith(code: 200, data: Data(),at: 0)
        })
    }
    
    func test_loadImage_deliversNonEmptyDataWith200HTTPResponse() {
        let (sut,client) = makeSUT()
        let nonEmptyData = Data("some-data".utf8)
        expect(sut, toCompleteWith: .success(nonEmptyData), when: {
            client.completeWith(code: 200, data: nonEmptyData,at: 0)
        })
    }
    
    func test_loadImage_doesNotDeliverResultAfterInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        var sut:RemoteFeedImageDataLoader? = RemoteFeedImageDataLoader(client: client)
        
        var receivedResult = [FeedImageLoader.Result]()
        _ = sut?.loadImageData(url: anyURL()) { result in receivedResult.append(result)
            
        }
        sut=nil
        client.completeWith(code: 200, data: anyData())
        
        XCTAssertTrue(receivedResult.isEmpty)
    }
    
    func test_cancelLoadImageURLTask_cancelsClientURLRequest() {
        let (sut,client) = makeSUT()
        let task = sut.loadImageData(url: anyURL()){_ in }
        XCTAssertEqual(client.cancelledURLs, [], "Expected no cancelledURL until task is cancelled")
        task.cancel()
        XCTAssertEqual(client.cancelledURLs, [anyURL()],"Expected one url after task is cancelled")
    }
    
    func test_loadImageFromURL_doesNotDeliverResultAfterCancellingTask() {
        let (sut,client) = makeSUT()
        let nonEmptyData = Data("non-empty data".utf8)
        var receivedResults = [FeedImageLoader.Result]()
        let task = sut.loadImageData(url: anyURL()){result in receivedResults.append(result) }
        task.cancel()
        client.completeWith(code: 200, data: anyData())
        client.completeWith(code: 404, data: nonEmptyData)
        client.completeWith(error: anyNSError())
        XCTAssertTrue(receivedResults.isEmpty,"should be empty after cancelling task")
    }
    
    
    //MARKERS: - HELPERS
    
    private func failure(error:RemoteFeedImageDataLoader.Error) -> FeedImageLoader.Result {
        return .failure(error)
    }
    
    
    
    private func expect(_ sut:RemoteFeedImageDataLoader,toCompleteWith  expectedResult:FeedImageLoader.Result,when  action:()->Void,file: StaticString = #filePath,
                         line: UInt = #line) {
        let url =  URL(string:"http\\any-url")!

        let exp = expectation(description: "wait for load image data response")
        _ = sut.loadImageData(url:url){ receivedResult in
            switch (receivedResult,expectedResult) {
            case let (.success(receivedData),.success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
            case let (.failure(receivedError as NSError),.failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult) but got \(receivedResult)",file: file,line: line)
                
                
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
        
    }
    
    private func makeSUT(file: StaticString = #filePath,
                         line: UInt = #line) -> (sut:RemoteFeedImageDataLoader,client:HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        trackForMemoryLeaks(sut,file: file, line: line)
        trackForMemoryLeaks(client,file: file, line: line)
        return (sut,client)
    }
    
    
}
