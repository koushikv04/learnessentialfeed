//
//  FeedImageLoader.swift
//  EssentialFeed
//
//  Created by Kouv on 20/12/2024.
//
import UIKit

public protocol FeedImageLoader {
    typealias Result = (Swift.Result<Data,Error>)
    func loadImageData(url:URL, completion:@escaping (Result) -> Void) -> FeedImageDataLoaderTask
}
