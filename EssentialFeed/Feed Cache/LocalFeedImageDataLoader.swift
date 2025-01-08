//
//  LocalFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Kouv on 05/01/2025.
//

public final class LocalFeedImageDataLoader {
    private var store:FeedImageDataStore
    public init(store:FeedImageDataStore) {
        self.store = store
    }
}
extension LocalFeedImageDataLoader {
    public typealias SaveResult = Swift.Result<Void,Swift.Error>
    
    public enum SaveError:Error {
        case failed
    }
    public func saveImageData(_ data:Data,for url:URL,completion:@escaping (SaveResult)->Void) {
        store.insert(data, for: url) { [weak self]result in
            guard self != nil else {return}
            completion(result.mapError{ _ in SaveError.failed})
        }
    }
}
extension LocalFeedImageDataLoader:FeedImageLoader {
    
    private class LoadImageDataTask:FeedImageDataLoaderTask {
        private var completion:((FeedImageLoader.Result) -> Void)?
        
        init(completion: @escaping (FeedImageLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func completeWith(_ result:FeedImageLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletion()
        }
        
        private func preventFurtherCompletion() {
            completion = nil
        }
    }
    
    
    
    public enum LoadError:Swift.Error {
        case failed
        case notFound
    }
    
    public typealias LoadResult = FeedImageLoader.Result
    
    public func loadImageData(url: URL, completion: @escaping (LoadResult) -> Void) ->  FeedImageDataLoaderTask {
        let task = LoadImageDataTask(completion: completion)
        store.retrieve(dataForURL: url){ [weak self] result in
            guard self != nil else {return}
            task.completeWith(result
                .mapError { _ in LoadError.failed}
                .flatMap{ data in data.map{.success($0)} ?? .failure(LoadError.notFound)})
        }
        return task
    }
    
    
    

}
