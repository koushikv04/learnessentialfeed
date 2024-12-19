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
        URLProtocolStub.startInterceptingRequests()
    }
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequests()
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
        let response = resultForError(data: nil, response: nil, error: error )
        XCTAssertEqual(response?.domain, error.domain)
        XCTAssertEqual(response?.code, error.code)
    }
    
    func test_getFromURL_failsOnInvalidRepresentationCases() {
        XCTAssertNotNil(resultForError(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultForError(data: nil, response: nonHTTPURLResponse(), error: nil))
        XCTAssertNotNil(resultForError(data: nil, response: anyHTTPURLResponse(), error: nil))
        XCTAssertNotNil(resultForError(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultForError(data: anyData(), response: nil, error: anyNSError()))
        XCTAssertNotNil(resultForError(data: nil, response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultForError(data: nil, response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultForError(data: anyData(), response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultForError(data: anyData(), response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultForError(data: anyData(), response: nonHTTPURLResponse(), error: nil))
    }
    func test_getFromURL_succeedsOnHTTPURLResponseWithData() {
        let data = anyData()
        let httpResponse = anyHTTPURLResponse()
        let receivedValues = resultValues(data: data, response: httpResponse, error: nil)
        XCTAssertEqual(receivedValues?.data, data)
        XCTAssertEqual(receivedValues?.response.url, httpResponse.url)
        XCTAssertEqual(receivedValues?.response.statusCode, httpResponse.statusCode)
    }
    func test_getFromURL_succeedsOnEmptyDataHTTPURLResponseWithNilData() {
        let httpResponse = anyHTTPURLResponse()
        let receivedValues = resultValues(data: nil, response: httpResponse, error: nil)
        let emptyData = Data()
        XCTAssertEqual(receivedValues?.data, emptyData)
        XCTAssertEqual(receivedValues?.response.url, httpResponse.url)
        XCTAssertEqual(receivedValues?.response.statusCode, httpResponse.statusCode)
    }
    
    //MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath,
                         line: UInt = #line)->HTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut,file: file,line: line)
        return sut
        
    }
    
    private func nonHTTPURLResponse() -> URLResponse {
        return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func anyData() -> Data {
        return Data("any data".utf8)
    }
    
    private func anyHTTPURLResponse() -> HTTPURLResponse {
        return  HTTPURLResponse(url: anyURL(), statusCode: 0, httpVersion: nil, headerFields: nil)!
    }
    
    private func resultForError(data:Data?,response:URLResponse?,error:Error?,file: StaticString = #filePath,line: UInt = #line) -> NSError? {
        let url = anyURL()
        var receivedErrorResponse:NSError?
        URLProtocolStub.stub(data:nil,response:nil, error:error)
        let expectation = self.expectation(description: "wait to get response from url")
        makeSUT(file: file, line:line).get(from:url) { result in
            switch result {
            case .failure(let receivedError as NSError):
                receivedErrorResponse = receivedError
                break
            default:
                XCTFail("Expected failure but got result \(result)")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        return receivedErrorResponse
    }
    
    private func resultValues(data:Data?,response:URLResponse?,error:Error?,file: StaticString = #filePath,line: UInt = #line) -> (data:Data,response:HTTPURLResponse)? {
        let url = anyURL()
        var receivedValues:(Data,HTTPURLResponse)?
        URLProtocolStub.stub(data:data,response:response, error:error)
        let expectation = self.expectation(description: "wait to get response from url")
        makeSUT(file: file, line:line).get(from:url) { result in
            switch result {
            case let .success(receivedData, receivedResponse):
                receivedValues = (receivedData,receivedResponse)
                break
            default:
                XCTFail("Expected success but got result \(result)")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        return receivedValues
    }
    
    private class URLProtocolStub:URLProtocol {
        private static var stub:Stub?
        private static var requestObserver:((URLRequest)->Void)?
        
        private struct Stub {
            var data:Data?
            var response:URLResponse?
            var error:Error?
        }
        
        static func observeRequests(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
        
        static func stub(data:Data?,response:URLResponse?, error:Error?) {
            stub = Stub(data: data,response: response, error: error)
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            requestObserver = nil
            stub = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
        
            if let observer = URLProtocolStub.requestObserver {
                client?.urlProtocolDidFinishLoading(self)
                return observer(request)
            }
            
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {
            
        }
    }
    

   

}
