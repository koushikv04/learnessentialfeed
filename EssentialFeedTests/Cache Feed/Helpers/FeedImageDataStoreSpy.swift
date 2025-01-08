//
//  FeedImageDataStoreSpy.swift
//  EssentialFeed
//
//  Created by Kouv on 05/01/2025.
//
import EssentialFeed
 class FeedImageDataStoreSpy:FeedImageDataStore {
    
    
    enum Message:Equatable {
        case retrieve(dataFor:URL)
        case insert(data:Data,url:URL)
    }
    
    var receivedMessages = [Message]()
    var retrievalCompletions = [(FeedImageDataStore.RetrievalResult) -> Void]()
    var insertionCompletions = [(FeedImageDataStore.InsertionResult) -> Void]()
     
    func retrieve(dataForURL url:URL,completion:@escaping( RetrieveCompletion)){
        receivedMessages.append(.retrieve(dataFor: url))
        retrievalCompletions.append(completion)
    }
    
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionCompletion)) {
        receivedMessages.append(.insert(data: data, url: url))
        insertionCompletions.append(completion)
    }
    
    func completeRetrieval(with error:Error,at index:Int = 0) {
        retrievalCompletions[index](.failure(error))
    }
    
    func completeRetrieval(with data:Data?,at index:Int = 0) {
        retrievalCompletions[index](.success(data))
    }
     
     func completeInsertion(with error:Error,at index:Int = 0) {
         insertionCompletions[index](.failure(error))
     }
     
     func completeInsertionSuccessfully(at index:Int = 0) {
         insertionCompletions[index](.success(()))
     }
}
