//
//  CoreDataFeedStore+FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Kouv on 06/01/2025.
//

extension CoreDataFeedStore:FeedImageDataStore {
    public func retrieve(dataForURL url: URL, completion: @escaping (RetrieveCompletion)) {
        perform { context in
            completion(
                Result {
                    try ManagedFeedImage.first(with: url, in: context)?.data
                })
        }
    }
    
    public func insert(_ data: Data, for url: URL, completion: @escaping (InsertionCompletion)) {
        perform { context in
            completion(Result{
                 try ManagedFeedImage.first(with: url, in: context)
                    .map{$0.data = data}
                    .map(context.save)
            })
            
            
        }
    }
    
}
