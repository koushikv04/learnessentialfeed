//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Kaushik on 22/08/2024.
//

import Foundation


public final class LocalFeedLoader {
    private let store:FeedStore
    private let currentDate: () -> Date
    public typealias SaveResult = Error?
    
    public init(feedStore:FeedStore, currentDate: @escaping () -> Date) {
        self.store = feedStore
        self.currentDate = currentDate
    }
    
    public func save(_ feed:[FeedImage],completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self] error in
            guard let self = self else {
                return
            }
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            }else {
                self.cache(feed, completion: completion)
            }
            
        }
    }
    
    private func cache(_ feed:[FeedImage],completion: @escaping (Error?) -> Void) {
        store.insert((feed.toLocal(), timestamp: self.currentDate())) {[weak self] error in
            guard self != nil else {return}
            completion(error)
        }
    }
    
}
extension LocalFeedLoader:FeedLoader {
    public typealias LoadResult = FeedLoader.Result

    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve(){[weak self]result in
            
            guard let self = self else {
                return
            }
            
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(.found(feed, timeStamp)) where FeedCachePolicy.validate(timeStamp, against: currentDate()):
                completion(.success(feed.toModels()))
            case .success:
                completion(.success([]))
            }
            
        }
    }
}

extension LocalFeedLoader {
    public func validateCache() {
        store.retrieve { [weak self] result in
            
            guard let self = self else {return}
            switch result {
            case .failure:
                self.store.deleteCachedFeed { _ in
                }
            case let .success(.found(_, timeStamp)) where !FeedCachePolicy.validate(timeStamp, against: currentDate()):
                self.store.deleteCachedFeed { _ in
                }
            case .success:
                break
            }
        }
        
    }
    
   
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        return map {LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)}
    }
}
private extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedImage] {
        return map {FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)}
    }
}
