//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Kouv on 05/01/2025.
//

public protocol FeedImageDataStore {
    typealias RetrievalResult = Swift.Result<Data?,Error>
    typealias InsertionResult = Swift.Result<Void,Error>
    
    typealias RetrieveCompletion = ((RetrievalResult) -> Void)
    typealias InsertionCompletion = ((InsertionResult) -> Void)
    
    func retrieve(dataForURL url:URL,completion:@escaping( RetrieveCompletion))
    func insert(_ data:Data,for url:URL,completion:@escaping (InsertionCompletion))
}
