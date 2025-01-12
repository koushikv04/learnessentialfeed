//
//  FeedImageCache.swift
//  EssentialFeed
//
//  Created by Kouv on 09/01/2025.
//

public protocol FeedImageCache {
    typealias Result = Swift.Result<Void,Error>
    func saveImageData(_ data:Data,for url:URL,completion:@escaping (Result)->Void)
}
