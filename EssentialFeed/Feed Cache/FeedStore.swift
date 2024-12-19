//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Kaushik on 22/08/2024.
//

import Foundation

public enum CacheFeed {
    case empty
    case found(feed:[LocalFeedImage], timestamp:Date)
}

public protocol FeedStore {
    typealias RetrievalResult = Result<CacheFeed,Error>

    typealias DeleteCompletion = ((Error?) -> Void)
    typealias InsertCompletion = ((Error?) -> Void)
    typealias RetrievalCompletion = ((RetrievalResult) -> Void)
    func insert(_ cache:(feed:[LocalFeedImage], timestamp: Date), completion: @escaping InsertCompletion)
    func deleteCachedFeed(completion: @escaping DeleteCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
}


