//
//  FeedPresenterTests.swift
//  EssentialFeediOSTests
//
//  Created by Kouv on 02/01/2025.
//

import XCTest
import EssentialFeed



final class FeedPresenterTests:XCTestCase {
    
    func test_init_doesNotSendMessagesToView() {
        let (view,_) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
        
    }
    
    func test_title_isLocalised() {
        XCTAssertEqual(FeedPresenter.title, localized("FEED_TITLE"))
    }
    
    func test_didStartLoading_displaysNoErrorMessageAndStartsLoading() {
        let (view,sut) = makeSUT()
        sut.didStartLoadingFeed()
        XCTAssertEqual(view.messages, [.display(errorMessage: nil),.display(isLoading: true)])
    }
    
    func test_didFinishLoading_displaysNoErrorMessageAndCompletesWithFeed() {
        let (view,sut) = makeSUT()
        let feed = UniqueImageFeed().models
        sut.didFinishLoadingFeed(with: feed)
        XCTAssertEqual(view.messages, [.display(isLoading: false),.display(feed: feed)])
    }
    
    func test_didFinishLoading_displaysErrorMessageAndFinishesLoading() {
        let (view,sut) = makeSUT()
        let error = anyNSError()
        sut.didFinishLoadingFeed(With: error)
        XCTAssertEqual(view.messages, [.display(isLoading: false),.display(errorMessage: localized("FEED_VIEW_CONNECTION_ERROR"))])
    }
    
    //MARK: - HELPERS
    
    func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
    func anyNSError() -> NSError {
        return NSError(domain: "test-domain", code: 1)
    }
    
    func uniqueImage() -> FeedImage {
        return FeedImage(id: UUID(),description: "any",location: "any", url: anyURL())
    }
    
    private func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
            let table = "Feed"
            let bundle = Bundle(for: FeedPresenter.self)
            let value = bundle.localizedString(forKey: key, value: nil, table: table)
            if value == key {
                XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
            }
            return value
        }

    func UniqueImageFeed() -> (models:[FeedImage],localItems:[LocalFeedImage]) {
        let items = [uniqueImage(),uniqueImage()]
        let localItems = items.map{LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)}
        return(items,localItems)
    }
    private func makeSUT(file: StaticString = #filePath,
                         line: UInt = #line) -> (view:ViewSpy,sut:FeedPresenter) {
        let view = ViewSpy()
        
        let sut = FeedPresenter(feedView: view, loadingView: view,errorView: view)
        trackForMemoryLeaks(sut,file: file,line: line)
        trackForMemoryLeaks(view,file: file,line: line)
        return (view,sut)
    }
    private class ViewSpy:FeedErrorView,FeedLoadingView,FeedView {
        enum Message:Hashable {
            case display(errorMessage:String?)
            case display(isLoading:Bool)
            case display(feed:[FeedImage])
        }
        
        var messages = Set<Message>()
        
        func display(_ viewModel: FeedErrorViewModel) {
            messages.insert(.display(errorMessage: viewModel.message))
        }
        
        func display(_ viewModel:FeedLoadingViewModel) {
            messages.insert(.display(isLoading: viewModel.isLoading))
        }
        
        func display(_ viewModel: FeedViewModel) {
            messages.insert(.display(feed: viewModel.feed))
        }
    }
}
