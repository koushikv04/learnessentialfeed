//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by Kaushik on 31/07/2024.
//

import Foundation
public class URLSessionHTTPClient:HTTPClient {
    private let session:URLSession
    
    public init(session:URLSession) {
        self.session = session
    }
    
    private struct unexpectedErrorRepresentation:Error {}
    
    private struct URLSessionTaskWrapper:HTTPClientTask {
        let task:URLSessionTask
        
        func cancel() {
            task.cancel()
        }
    }
    
    public func get(from url:URL, completion : @escaping (HTTPClient.Result)->Void)->HTTPClientTask {
        
       let task = session.dataTask(with: url) {data,response,error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success((data, response)))
            }else {
                completion(.failure(unexpectedErrorRepresentation()))
            }
        }
        task.resume()
        return URLSessionTaskWrapper(task: task)
    }
}
