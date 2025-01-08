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

public typealias CacheFeed = (feed:[LocalFeedImage],timeStamp:Date)
public protocol FeedStore {

    typealias DeletionResult = Result<Void,Error>
    typealias DeleteCompletion = ((DeletionResult) -> Void)
    
    typealias InsertionResult = Result<Void,Error>
    typealias InsertCompletion = ((InsertionResult) -> Void)
    
    typealias RetrievalResult = Swift.Result<CacheFeed?,Error>
    typealias RetrievalCompletion = (RetrievalResult) -> Void
    
    func insert(_ feed:[LocalFeedImage], timestamp: Date, completion: @escaping InsertCompletion)
    func deleteCachedFeed(completion: @escaping DeleteCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
}


