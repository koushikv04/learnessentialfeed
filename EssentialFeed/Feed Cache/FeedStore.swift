//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Kaushik on 22/08/2024.
//

import Foundation

public enum RetrieveCachedFeedResult {
    case empty
    case found(feed:[LocalFeedImage], timestamp:Date)
    case failure(Error)
}

public typealias CachedFeed = (feed:[LocalFeedImage],timeStamp:Date)
public protocol FeedStore {

    typealias DeletionResult = Result<Void,Error>
    typealias DeletionCompletion = ((DeletionResult) -> Void)
    
    typealias InsertionResult = Result<Void,Error>
    typealias InsertionCompletion = ((InsertionResult) -> Void)
    
    typealias RetrievalResult = Swift.Result<CachedFeed?,Error>
    typealias RetrievalCompletion = (RetrievalResult) -> Void
    
    func insert(_ feed:[LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
}


