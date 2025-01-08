//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Kaushik on 29/08/2024.
//

import Foundation

func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
}

func anyNSError() -> NSError {
    return NSError(domain: "test-domain", code: 1)
}

func anyData() -> Data {
    return Data("invalid-data".utf8)
}

