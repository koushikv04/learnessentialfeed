//
//  HTTPClientSpy.swift
//  EssentialFeed
//
//  Created by Kouv on 04/01/2025.
//
import EssentialFeed

class HTTPClientSpy:HTTPClient {

    private struct Task:HTTPClientTask {
        let callback:()->Void
        func cancel() {
            callback()
        }
    }
    
    var requestedURLs:[URL] {
        return completions.map{$0.url}
    }
    private(set) var cancelledURLs = [URL]()
    var completions = [(url:URL,completion:(HTTPClient.Result) -> Void)]()
    
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        completions.append((url,completion))
        return Task{ [weak self] in
            self?.cancelledURLs.append(url)
        }
    }
    
    func completeWith(_ result:HTTPClient.Result, at index:Int = 0) {
        completions[index].completion(result)
    }
    
    func completeWith(code:Int,data:Data,at index:Int = 0) {
        let response = HTTPURLResponse(url: requestedURLs[index], statusCode: code, httpVersion: nil, headerFields: nil)!
        completions[index].completion(.success((data,response)))
    }
    
    func completeWith(error:Error,at index:Int = 0) {
        completions[index].completion(.failure(error))
    }
    
    
}
