//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Kaushik on 24/07/2024.
//

import Foundation

public protocol HTTPClientTask {
    func cancel()
}

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data,HTTPURLResponse),Error>

    @discardableResult
    func get(from url:URL,completion: @escaping (Result) -> Void) -> HTTPClientTask
}
