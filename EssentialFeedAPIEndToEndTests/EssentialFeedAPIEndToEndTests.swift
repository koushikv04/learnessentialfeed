//
//  EssentialFeedAPIEndToEndTests.swift
//  EssentialFeedAPIEndToEndTests
//
//  Created by Kaushik on 31/07/2024.
//

import XCTest
import EssentialFeed
final class EssentialFeedAPIEndToEndTests: XCTestCase {

    func test_endToEndGetFeedResult_matchesFixedAccountTestData() {
        switch getFeedResult() {
        case .success(let imageFeed):
            XCTAssertEqual(imageFeed.count, 8, "expected 8 images in test image feed")
            imageFeed.enumerated().forEach { (index,item) in
                XCTAssertEqual(item, expectedImage(at:index),"invalid entry at index \(index)")
            }
        case .failure(let error):
            XCTFail("should have succeeded but failed with error \(error)")
        default:
            XCTFail("Expected success but got no result")
        }
    }
    
    func test_endToEndGetImageDataFromServer_matchesFixedAccountData() {
        let result = getFeedImageResult()
        switch result {
        case let .success(data):
            XCTAssertFalse(data.isEmpty,"Expected to get some image data ")
        case let .failure(error):
            XCTFail("should have successfully fetched image data but got \(error) instead")
        default:
            XCTFail("should have successfully fetched image data but got no result")
        }
        
    }
    
    //MARK: - Helpers
    func expectedImage(at index:Int) -> FeedImage {
        return FeedImage(id: id(at:index), description: description(at:index), location: location(at:index), url: imageURL(at:index))
    }
    
    private func getFeedImageResult(file: StaticString = #filePath,
                              line: UInt = #line) -> FeedImageLoader.Result? {
        let testServerURL = feedTestServerURL.appendingPathComponent("/73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6/image")
        
        let loader = RemoteFeedImageDataLoader(client: ephemeralClient())
        trackForMemoryLeaks(loader,file: file,line: line)
        var receivedResult:FeedImageLoader.Result?
        let exp = expectation(description: "wait to fetch image")
        _ = loader.loadImageData(url: testServerURL) { result in
            receivedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5.0)
        return receivedResult
    }
    
    private func getFeedResult(file: StaticString = #filePath,
                               line: UInt = #line) -> FeedLoader.Result? {
        
        let loader = RemoteFeedLoader(url: feedTestServerURL, client: ephemeralClient())
        trackForMemoryLeaks(loader, file: file, line: line)
        var feedResult:FeedLoader.Result?
        let exp = self.expectation(description: "wait to fetch feed")
        
        loader.load { result in
            feedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5.0)
        return feedResult
    }
    
    private func id(at index: Int) -> UUID {
            return UUID(uuidString: [
                "73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6",
                "BA298A85-6275-48D3-8315-9C8F7C1CD109",
                "5A0D45B3-8E26-4385-8C5D-213E160A5E3C",
                "FF0ECFE2-2879-403F-8DBE-A83B4010B340",
                "DC97EF5E-2CC9-4905-A8AD-3C351C311001",
                "557D87F1-25D3-4D77-82E9-364B2ED9CB30",
                "A83284EF-C2DF-415D-AB73-2A9B8B04950B",
                "F79BD7F8-063F-46E2-8147-A67635C3BB01"
            ][index])!
        }
    
    private func description(at index: Int) -> String? {
            return [
                "Description 1",
                nil,
                "Description 3",
                nil,
                "Description 5",
                "Description 6",
                "Description 7",
                "Description 8"
            ][index]
        }
    private func location(at index: Int) -> String? {
            return [
                "Location 1",
                "Location 2",
                nil,
                nil,
                "Location 5",
                "Location 6",
                "Location 7",
                "Location 8"
            ][index]
        }
    private func imageURL(at index: Int) -> URL {
            return URL(string: "https://url-\(index+1).com")!
        }
    
    private var feedTestServerURL: URL {
            return URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
        }
    
    private func ephemeralClient(file: StaticString = #filePath,
                                 line: UInt = #line) -> HTTPClient {
        let config = URLSessionConfiguration.ephemeral
        let urlSession = URLSession(configuration: config)
        let client = URLSessionHTTPClient(session: urlSession)
        trackForMemoryLeaks(client,file: file, line: line)
        return client
    }
}
