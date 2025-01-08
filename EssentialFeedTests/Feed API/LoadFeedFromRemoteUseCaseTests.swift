//
//  LoadFeedFromRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Kaushik on 05/02/2024.
//

import XCTest
import EssentialFeed

final class LoadFeedFromRemoteUseCaseTests: XCTestCase {
    
    func test_init_doesnotRequestDatafromURL() {
        let (_,client) = makeSUT()
        XCTAssertTrue(client.requestedURLs.isEmpty)
        
    }
    
    func test_load_requestDatafromURL() {
        let url = URL(string: "https://www.a-url.com")!
        let (sut,client) = makeSUT(url: url)
        
        sut.load{_ in }

        XCTAssertEqual(client.requestedURLs,[url])
    }
    
    func test_loadtwice_requestDataTwice() {
        let url = URL(string: "https://www.a-url.com")!
        let (sut,client) = makeSUT(url: url)
        
        sut.load{_ in }
        sut.load{_ in }

        XCTAssertEqual(client.requestedURLs,[url,url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut,client) = makeSUT()
        
        expect(sut, toCompleteWithResult: .failure(RemoteFeedLoader.Error.connectivity)) {
            let clientError = NSError(domain: "Test", code: 0, userInfo: nil)
            client.completeWith(error: clientError)

        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut,client) = makeSUT()
        
        let errorCodes = [199,201,300,400,500]
        errorCodes.enumerated().forEach { index,code in
            expect(sut, toCompleteWithResult: .failure(RemoteFeedLoader.Error.invalidData)) {
                let json = makeItemsJSON([])
                client.completeWith(code:code, data: json,at: index)
            }
        }
        
       
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut,client) = makeSUT()
        expect(sut, toCompleteWithResult: .failure(RemoteFeedLoader.Error.invalidData)) {
            let invalidData = Data("invalidJSON".utf8)
            client.completeWith(code: 200, data:invalidData)
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponsewithEmptyJSONList() {
        let (sut,client) = makeSUT()
        expect(sut, toCompleteWithResult: .success([])) {
            client.completeWith(code: 200,data: makeItemsJSON([]))
        }

    }
    
    func test_load_deliverFeedItemsOn200HTTPResponseWithJSONItems() {
        let (sut,client) = makeSUT()
        let feedItem1 = makeItem(uuid: UUID(), imageURL: URL(string: "https://a-url.com")!)
        let feedItem2 = makeItem(uuid: UUID(),location: "some location", description: "some description", imageURL: URL(string: "https://another-url.com")!)
        
        expect(sut, toCompleteWithResult: .success([feedItem1.model,feedItem2.model])) {
            let json = makeItemsJSON([feedItem1.json,feedItem2.json])
            client.completeWith(code: 200,data: json)
        }
    }
    
    func test_load_doesNotDeliverAfterSUThasbeendeallocated() {
        let url = URL(string: "http://some-url.com")!
        let client = HTTPClientSpy()
        var sut:RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)
        var capturedResults = [RemoteFeedLoader.Result]()
        sut?.load{capturedResults.append($0)}
        
        sut = nil
        
        client.completeWith(code: 200, data: makeItemsJSON([]))
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    
    //MARK:- helpers
    private func makeSUT(url:URL = URL(string: "https://www.a-url.com")!,file: StaticString = #filePath,
                         line: UInt = #line) -> (sut:RemoteFeedLoader,client:HTTPClientSpy) {
        let client = HTTPClientSpy()
        let remoteFeedLoader = RemoteFeedLoader(url: url, client: client)
        trackForMemoryLeaks(remoteFeedLoader,file: file,line: line)
        trackForMemoryLeaks(client,file: file,line: line)
        return (sut:remoteFeedLoader,client:client)
    }
    
    private func expect(_ sut:RemoteFeedLoader,toCompleteWithResult expectedResult:RemoteFeedLoader.Result, when action: () -> Void,file: StaticString = #filePath,
                        line: UInt = #line) {
        let expectation = self.expectation(description: "wait for load completion")
        sut.load{receivedResult in
            switch (receivedResult,expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case let (.failure(receivedError as RemoteFeedLoader.Error),.failure(expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("suppose to get \(expectedResult) but got result \(receivedResult)", file: file, line: line)
                
            }
            expectation.fulfill()
        }
        action()
        wait(for: [expectation], timeout: 1.0)
    }
    
    private func makeItem(uuid:UUID, location:String? = nil, description:String? = nil, imageURL:URL) -> (model:FeedImage, json:[String:Any]) {
        let feedItem = FeedImage(id: uuid, description: description, location: location, url: imageURL)
        let itemJSON = ["id":uuid.uuidString,
                        "location":location,
                        "description": description,
                         "image":imageURL.absoluteString]
            .compactMapValues{$0}
        return (feedItem,itemJSON)
    }
    
    private func makeItemsJSON(_ items:[[String:Any]]) -> Data {
        let json = ["items":items]
        let data = try! JSONSerialization.data(withJSONObject: json)
        return data
    }

    

}
