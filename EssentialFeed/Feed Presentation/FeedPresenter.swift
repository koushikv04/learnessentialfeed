//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by Kouv on 02/01/2025.
//


public protocol FeedView {
    func display(_ viewModel:FeedViewModel)
}

public protocol FeedLoadingView {
    func display(_ viewModel:FeedLoadingViewModel)
}

public protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

public final class FeedPresenter {
    private let errorView:FeedErrorView
    private let loadingView:FeedLoadingView
    private let feedView:FeedView
    
    public init(feedView:FeedView,loadingView:FeedLoadingView,errorView:FeedErrorView) {
        self.errorView = errorView
        self.loadingView = loadingView
        self.feedView = feedView
    }
    public static var title:String {
        return NSLocalizedString("FEED_TITLE",tableName: "Feed", bundle: Bundle(for: FeedPresenter.self), comment: "title for the feed view")
    }
    
    public func didStartLoadingFeed() {
        errorView.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoadingFeed(with feed:[FeedImage]) {
        feedView.display(FeedViewModel(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    private var feedLoadError: String {
            return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR",
                 tableName: "Feed",
                 bundle: Bundle(for: FeedPresenter.self),
                 comment: "Error message displayed when we can't load the image feed from the server")
        }
    
    public func didFinishLoadingFeed(With error:Error) {
        errorView.display(FeedErrorViewModel(message: feedLoadError))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}
