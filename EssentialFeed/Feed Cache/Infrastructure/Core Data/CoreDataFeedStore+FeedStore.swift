//
//  CoreDataFeedStore+FeedStore.swift
//  EssentialFeed
//
//  Created by Kouv on 06/01/2025.
//

extension CoreDataFeedStore:FeedStore {
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        perform {context in
            completion(Result {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timeStamp = timestamp
                managedCache.feed = ManagedFeedImage.images(from: feed, in: context)
                
                try context.save()
            })
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        perform {context in
            completion(Result {
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
            })
        }
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        perform { context in
            completion(Result {
                try ManagedCache.find(in: context).map{
                    CachedFeed(feed:$0.localFeed,timeStamp:$0.timeStamp)
                }
            })
        }
    }
}
