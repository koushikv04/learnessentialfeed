//
//  RemoteFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Kouv on 04/01/2025.
//

public final class RemoteFeedImageDataLoader:FeedImageLoader {
    private let client:HTTPClient
    
    public init(client:HTTPClient) {
        self.client = client
    }
    
    public enum Error:Swift.Error {
        case invalidData
        case connectivity
    }
    
    private final class HTTPTaskWrapper:FeedImageDataLoaderTask {
        var wrapped:HTTPClientTask?
        private var completion:((FeedImageLoader.Result)->Void)?
        
        init( completion: @escaping (FeedImageLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func cancel() {
            preventFurtherCompletion()
            wrapped?.cancel()
        }
        private func preventFurtherCompletion() {
            completion = nil
        }
        
        func completeWith(_ result:FeedImageLoader.Result) {
            completion?(result)
        }
    }
    
    public func loadImageData(url:URL, completion:@escaping(FeedImageLoader.Result)->Void) -> FeedImageDataLoaderTask {
        let task = HTTPTaskWrapper(completion: completion)
        task.wrapped = client.get(from: url) {[weak self] result in
            guard self != nil else {return}
            
            task.completeWith(result
                .mapError{_ in Error.connectivity}
                .flatMap({ data,response in
                    let isValidResponse = response.isOK && !data.isEmpty
                    return isValidResponse ? .success(data) : .failure(Error.invalidData)
                }))
        
        }
        return task
    }
}
