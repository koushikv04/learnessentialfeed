//
//  FeedCacheTestsHelpers.swift
//  EssentialFeedTests
//
//  Created by Kaushik on 29/08/2024.
//

import Foundation
import EssentialFeed

func uniqueImage() -> FeedImage {
    return FeedImage(id: UUID(),description: "any",location: "any", url: anyURL())
}

func UniqueImageFeed() -> (models:[FeedImage],localItems:[LocalFeedImage]) {
    let items = [uniqueImage(),uniqueImage()]
    let localItems = items.map{LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)}
    return(items,localItems)
}

extension Date {
    
    func minusFeedCacheMaxAge() -> Date {
        return adding(days: -feedCacheMaxAgeInDays)
    }
    
    private var feedCacheMaxAgeInDays:Int {
        return 7
    }
    
    private func adding(days:Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day,value: days, to: self)!
    }
    
}
extension Date {
    func adding(seconds:TimeInterval) -> Date {
        return self + seconds
    }
}
