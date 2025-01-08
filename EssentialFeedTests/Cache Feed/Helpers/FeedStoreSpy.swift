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
    
    var deleteCompletions = [DeleteCompletion]()
    var insertCompletions = [InsertCompletion]()
    var retrievalCompletions = [RetrievalCompletion]()
    
    enum ReceivedMessage:Equatable {
        case deleteCacheFeed
        case insert([LocalFeedImage], Date)
        case retrieve
    }
    
    var receivedMessages = [ReceivedMessage]()
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertCompletion) {
        receivedMessages.append(.insert(feed, timestamp))
        insertCompletions.append(completion)
    }
    
    func deleteCachedFeed(completion: @escaping DeleteCompletion) {
        deleteCompletions.append(completion)
        receivedMessages.append(.deleteCacheFeed)
    }
    
    func completeDeletion(with error:Error, at index:Int = 0) {
        deleteCompletions[index](.failure(error))
    }
    
    func completeDeletionSuccessfully(at index:Int = 0) {
        deleteCompletions[index](.success(()))
    }
    
    func completeInsertion(with error:Error, at index:Int = 0) {
        insertCompletions[index](.failure(error))
    }
    func completeInsertionSuccessfully(at index:Int = 0) {
        insertCompletions[index](.success(()))
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        retrievalCompletions.append(completion)
        receivedMessages.append(.retrieve)
    }
    
    func completeRetrieval(with error:Error, at index:Int = 0) {
        retrievalCompletions[index](.failure( error))
    }
    
    func completeRetrievalWithEmptyCache(at index:Int = 0) {
        retrievalCompletions[index](.success(.none))
    }
    
    func completeRetrieval(with feed:[LocalFeedImage],timeStamp:Date,at index:Int = 0) {
        retrievalCompletions[index](.success((feed: feed, timeStamp: timeStamp)))
    }
} 
