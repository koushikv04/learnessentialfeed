//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by Kouv on 02/01/2025.
//

public struct FeedImageViewModel<Image> {
    public var location:String?
    public var description:String?
    public  var image:Image?
    public var isLoading:Bool
    public var shouldRetry:Bool
    public var hasLocation:Bool {
        return location != nil
    }
}
