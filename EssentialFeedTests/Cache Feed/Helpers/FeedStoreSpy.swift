//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Kaushik on 23/08/2024.
//

import Foundation
import EssentialFeed

class FeedStoreSpy:FeedStore {
    var insertions = [(items:[LocalFeedImage], timestamp:Date)]()
    typealias InsertCompletion = ((Error?) -> Void)
    
    var deleteCompletions = [DeleteCompletion]()
    var insertCompletions = [InsertCompletion]()
    var retrievalCompletions = [RetrievalCompletion]()
    
    enum ReceivedMessage:Equatable {
        case deleteCacheFeed
        case insert([LocalFeedImage], Date)
        case retrieve
    }
    
    var receivedMessages = [ReceivedMessage]()
    
    func insert(_ cache:(feed:[LocalFeedImage], timestamp: Date), completion: @escaping InsertCompletion) {
        receivedMessages.append(.insert(cache.feed, cache.timestamp))
        insertCompletions.append(completion)
    }
    
    func deleteCachedFeed(completion: @escaping DeleteCompletion) {
        deleteCompletions.append(completion)
        receivedMessages.append(.deleteCacheFeed)
    }
    
    func completeDeletion(with error:Error, at index:Int = 0) {
        deleteCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index:Int = 0) {
        deleteCompletions[index](nil)
    }
    
    func completeInsertion(with error:Error, at index:Int = 0) {
        insertCompletions[index](error)
    }
    func completeInsertionSuccessfully(at index:Int = 0) {
        insertCompletions[index](nil)
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        retrievalCompletions.append(completion)
        receivedMessages.append(.retrieve)
    }
    
    func completeRetrieval(with error:Error, at index:Int = 0) {
        retrievalCompletions[index](.failure( error))
    }
    
    func completeRetrievalWithEmptyCache(at index:Int = 0) {
        retrievalCompletions[index](.success(.empty))
    }
    
    func completeRetrieval(with feed:[LocalFeedImage],timeStamp:Date,at index:Int = 0) {
        retrievalCompletions[index](.success(.found(feed: feed, timestamp: timeStamp)))
    }
} 
