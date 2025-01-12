//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Kouv on 09/01/2025.
//

public protocol FeedCache {
    typealias Result = Swift.Result<Void,Error>
    
    func save(_ feed:[FeedImage],completion: @escaping (Result) -> Void)
}
