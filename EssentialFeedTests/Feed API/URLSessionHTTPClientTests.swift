//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Kaushik on 29/07/2024.
//

import XCTest
import EssentialFeed

final class URLSessionHTTPClientTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.clearStub()
    }

    func test_getFromURL_performGETrequestwithURL() {
        let url = anyURL()
        let expectation = self.expectation(description: "wait to get response from url")
        expectation.expectedFulfillmentCount = 1
        var receivedRequest = [URLRequest]()
        URLProtocolStub.observeRequests { request in
            receivedRequest.append(request)
        }
        makeSUT().get(from:url) { _ in
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedRequest.count, 1)
        XCTAssertEqual(receivedRequest.first?.url, url)
        XCTAssertEqual(receivedRequest.first?.httpMethod, "GET")

    }
    func test_getFromURL_failsOnRequestError() {
        let error =  anyNSError()
        let receivedError = resultForError((data: nil, response: nil, error: error )) as? NSError
        XCTAssertEqual(receivedError?.domain, error.domain)
        XCTAssertEqual(receivedError?.code, error.code)
    }
    
    func test_getFromURL_failsOnInvalidRepresentationCases() {
        XCTAssertNotNil(resultForError((data: nil, response: nil, error: nil)))
        XCTAssertNotNil(resultForError((data: nil, response: nonHTTPURLResponse(), error: nil)))
        XCTAssertNotNil(resultForError((data: anyData(), response: nil, error: nil)))
        XCTAssertNotNil(resultForError((data: anyData(), response: nil, error: anyNSError())))
        XCTAssertNotNil(resultForError((data: nil, response: nonHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultForError((data: nil, response: anyHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultForError((data: anyData(), response: anyHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultForError((data: anyData(), response: nonHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultForError((data: anyData(), response: nonHTTPURLResponse(), error: nil)))
    }
    func test_getFromURL_succeedsOnHTTPURLResponseWithData() {
        let data = anyData()
        let httpResponse = anyHTTPURLResponse()
        let receivedValues = resultValuesFor((data: data, response: httpResponse, error: nil))
        XCTAssertEqual(receivedValues?.data, data)
        XCTAssertEqual(receivedValues?.response.url, httpResponse.url)
        XCTAssertEqual(receivedValues?.response.statusCode, httpResponse.statusCode)
    }
    func test_getFromURL_succeedsOnEmptyDataHTTPURLResponseWithNilData() {
        let httpResponse = anyHTTPURLResponse()
        let receivedValues = resultValuesFor((data: nil, response: httpResponse, error: nil))
        let emptyData = Data()
        XCTAssertEqual(receivedValues?.data, emptyData)
        XCTAssertEqual(receivedValues?.response.url, httpResponse.url)
        XCTAssertEqual(receivedValues?.response.statusCode, httpResponse.statusCode)
    }
    
    func test_cancelGetFromURLTask_cancelsURLRequest() {
        var task:HTTPClientTask?
        URLProtocolStub.onStartLoading {
            task?.cancel()
        }
        let receivedError = resultForError(taskHandler: { task = $0}) as? NSError
        XCTAssertEqual(receivedError?.code, URLError.cancelled.rawValue)
    }
    
    //MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath,
                         line: UInt = #line)->HTTPClient {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolStub.self]
        let urlSession = URLSession(configuration: config)
        let sut = URLSessionHTTPClient(session: urlSession)
        trackForMemoryLeaks(sut,file: file,line: line)
        return sut
        
    }
    
    private func nonHTTPURLResponse() -> URLResponse {
        return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }

    
    private func anyHTTPURLResponse() -> HTTPURLResponse {
        return  HTTPURLResponse(url: anyURL(), statusCode: 0, httpVersion: nil, headerFields: nil)!
    }
    
    private func resultValuesFor(_ values:(data:Data?,response:URLResponse?,error:Error?),file: StaticString = #filePath,line: UInt = #line) -> (data:Data,response:HTTPURLResponse)? {
        let result = resultFor(values,file: file,line: line)
        switch result {
        case let .success((data, response)):
            return (data, response)
        default:
            XCTFail("Expected success, got \(result) instead", file: file, line: line)
            return nil
        }
    }
    
    private func resultForError(_ values:(data:Data?,response:URLResponse?,error:Error?)? = nil,taskHandler:(HTTPClientTask) -> Void = { _ in },file: StaticString = #filePath,line: UInt = #line) -> Error? {
        let result = resultFor(values, taskHandler: taskHandler,file: file,line: line)
        switch result {
        case let .failure(error):
            return error
        default:
            XCTFail("Expected failure but got result \(result) instead",file: file,line: line)
            return nil
        }
    }
    
    private func resultFor(_ values:(data:Data?,response:URLResponse?,error:Error?)?,taskHandler:(HTTPClientTask) -> Void = {_ in },file: StaticString = #filePath,line: UInt = #line) -> HTTPClient.Result {
        var receivedValues:HTTPClient.Result!
        values.map { URLProtocolStub.stub(data:$0,response:$1, error:$2)}
        let expectation = self.expectation(description: "wait to get response from url")
        taskHandler(makeSUT(file: file, line:line).get(from:anyURL()) { result in
            receivedValues = result
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1.0)
        return receivedValues
    }
    
    
    

   

}
