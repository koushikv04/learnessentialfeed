//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by Kaushik on 02/09/2024.
//

import Foundation
internal enum FeedCachePolicy {
    
    private static let calendar = Calendar(identifier: .gregorian)
    private static var maxCacheAgeInDays:Int {
        return 7
    }
    
    internal static func validate(_ timeStamp:Date, against date:Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timeStamp) else {
            return false
        }
        return date < maxCacheAge
    }
}
