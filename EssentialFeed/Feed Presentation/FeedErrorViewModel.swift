//
//  FeedErrorViewModel.swift
//  EssentialFeed
//
//  Created by Kouv on 02/01/2025.
//

public struct FeedErrorViewModel {
    public let message: String?
    
    static var noError:FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }
    
    static func error(message:String) -> FeedErrorViewModel {
        return FeedErrorViewModel(message: message)
    }
}
