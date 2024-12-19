//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Kaushik on 04/02/2024.
//

import Foundation

public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage],Error>
    func load (completion: @escaping(Result) -> Void)
}
