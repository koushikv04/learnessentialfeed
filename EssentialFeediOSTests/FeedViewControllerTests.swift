//
//  FeedViewControllerTests.swift
//  EssentialFeed
//
//  Created by Kouv on 17/12/2024.
//

import XCTest
import UIKit
import EssentialFeed
import EssentialFeediOS

final class FeedViewControllerTests:XCTestCase {
    
    
    func test_loadFeedActions_requestFeedFromLoader() {
        let (sut,loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0,"Expected no loading requets before view is loaded")

        sut.loadViewIfNeeded()
        
        sut.beginAppearanceTransition(true, animated: false)
        sut.endAppearanceTransition()
        
        XCTAssertEqual(loader.loadCallCount,1, "expected one loading request once view is loaded")
        
        sut.simulateUserInitiatedFeedReload()
        
        XCTAssertEqual(loader.loadCallCount,2, "expected another loading request once user initiates reload")
        
        sut.simulateUserInitiatedFeedReload()
        
        XCTAssertEqual(loader.loadCallCount,3,"expected another loading request once user initiates reload")

    }
    
    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut,loader) = makeSUT()

        sut.loadViewIfNeeded()

        sut.replaceRefreshControlWithFakeForiOS17support()
        
        XCTAssertEqual(sut.isShowingLoadingIndicator,false,"Expected no loading indicator before view is loaded")

        sut.beginAppearanceTransition(true, animated: false)
        sut.endAppearanceTransition()

        XCTAssertEqual(sut.isShowingLoadingIndicator,true, "Expected loading indicator once view is loaded")
        
        loader.completeFeedLoading(at : 0)
        
        XCTAssertEqual(sut.isShowingLoadingIndicator,false,"Expected no loading indicator when feed loaded successfully")
        
        sut.simulateUserInitiatedFeedReload()
                
        XCTAssertEqual(sut.isShowingLoadingIndicator, true, "Expected loading indicator on user initiated refresh")

        loader.completeFeedLoadingWithError(at: 1)
        
        XCTAssertEqual(sut.isShowingLoadingIndicator, false,"Expected no loading indicator once user initated refresh completes with error")
    }
    
    func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
        let image0 = makeImage(description:"a description",location:"a location")
        let image1 = makeImage(description:nil,location:"a location")
        let image2 = makeImage(description:"a description",location:nil)
        let image3 = makeImage(description:nil,location:nil)

        let (sut,loader) = makeSUT()
        sut.loadViewIfNeeded()
        sut.beginAppearanceTransition(true, animated: false)
        sut.endAppearanceTransition()
        
        assertThat(sut, isRendering: [])
        
        loader.completeFeedLoading(with: [image0],at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserInitiatedFeedReload()
        
        loader.completeFeedLoading(with: [image0,image1,image2,image3], at: 1)
        assertThat(sut, isRendering: [image0,image1,image2,image3])

    }
    
    func test_loadFeedCompletion_shouldNotAlterExisitingFeedOnError() {
        let (sut,loader) = makeSUT()
        let image0 = makeImage(description:"a description",location:"a location")
        sut.loadViewIfNeeded()
        sut.beginAppearanceTransition(true, animated: false)
        sut.endAppearanceTransition()
        loader.completeFeedLoading(with: [image0],at: 0)
        assertThat(sut, isRendering: [image0])
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoadingWithError( at: 1)
        assertThat(sut, isRendering: [image0])
    }

    func test_feedImage_loadsImageURLWhenVisible() {
        let image0 = makeImage(url: URL(string: "any-url")!)
        let image1 = makeImage(url: URL(string: "any-url")!)
        let (sut,loader) = makeSUT()
        sut.loadViewIfNeeded()
        sut.beginAppearanceTransition(true, animated: false)
        sut.endAppearanceTransition()
        
        loader.completeFeedLoading(with: [image0,image1], at: 0)
        
        XCTAssertEqual(loader.loadedImageURLs, [],"Expected no loading of image until view is visible")

    }
    
    //MARK: - HELPERS
    
    private func makeSUT(file: StaticString = #filePath,
                         line: UInt = #line) -> (sut:FeedViewController,loader:LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        trackForMemoryLeaks(sut, file:file, line: line)
        trackForMemoryLeaks(loader,file: file,line: line)
        return (sut,loader)
    }
    
    private func makeImage(description:String? = nil,location:String? = nil, url:URL = URL(string:"any-url")!) -> FeedImage {
        return FeedImage(id: UUID(),description: description,location: location, url: url)
    }
    
    private func assertThat(_ sut:FeedViewController, isRendering feed:[FeedImage],file: StaticString = #filePath,
                            line: UInt = #line) {
        guard sut.numberOfRenderedImageviews() == feed.count else {
            return XCTFail("Exptected \(feed.count) images but got \(sut.numberOfRenderedImageviews()) instead",file: file, line: line)
        }
        feed.enumerated().forEach { index,image in
            assertThat(sut, hasViewConfiguredFor: image, at: index,file: file,line: line)
        }
    }
    private func assertThat(_ sut:FeedViewController,hasViewConfiguredFor img:FeedImage, at index:Int,file: StaticString = #filePath,
                            line: UInt = #line) {
        let view = sut.feedImageView(at:index) as? FeedImageCell
        guard let cell = view else {
            return XCTFail("Expected \(FeedImageCell.self) instance but got \(String(describing:view))instead ",file: file,line: line)
        }
        let shouldLocationBeVisible = img.location != nil
        XCTAssertEqual(cell.isShowingLocation,shouldLocationBeVisible,"Expected 'isshowinglocation' to be \(shouldLocationBeVisible) for image view at \(index)",file: file, line: line)
        XCTAssertEqual(cell.locationLabel.text,img.location,"Expected 'location' to be \(String(describing: img.location)) for image view at \(index)",file: file, line: line)
        XCTAssertEqual(cell.descriptionLabel.text,img.description,"Expected 'description' to be \(String(describing: img.description)) for image view at \(index)",file: file, line: line)
    }
    class LoaderSpy:FeedLoader {
        
        var loadedImageURLs:[URL] {
            return []
        }
        
        var loadCallCount:Int {
            return completions.count
        }
        var completions = [(FeedLoader.Result) -> Void]()
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completions.append(completion)
        }
        
        func completeFeedLoading(with feed:[FeedImage] = [],at index:Int) {
            completions[index](.success(feed))
        }
        
        func completeFeedLoadingWithError( at index: Int) {
            let error = NSError(domain: "any domain", code: 500, userInfo: nil)
            completions[index](.failure(error))
        }
        
    }
    
    
}
extension FeedImageCell {
    var isShowingLocation:Bool {
        return !locationContainer.isHidden
    }
    
    var locationText:String? {
        return locationLabel.text
    }
    
    var descriptionText:String? {
        return descriptionLabel.text
    }
}
extension FeedViewController {
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    var isShowingLoadingIndicator:Bool {
        return refreshControl?.isRefreshing == true
    }
    
    func replaceRefreshControlWithFakeForiOS17support() {
        let fake = FakeRefreshControl()
        refreshControl?.allTargets.forEach({ target in
            refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach({ action in
                fake.addTarget(target, action: Selector(action), for: .valueChanged)
            })
        })
        refreshControl = fake
    }
    
    func numberOfRenderedImageviews() -> Int {
        return tableView.numberOfRows(inSection: feedImagesSection)
    }
    
    private var feedImagesSection:Int {
        return 0
    }
    
    func feedImageView(at index:Int) -> UITableViewCell?  {
        let ds = tableView.dataSource
        let indexPath = IndexPath(row: index, section: feedImagesSection)
        return ds?.tableView(tableView, cellForRowAt: indexPath)
    }
}

private class FakeRefreshControl:UIRefreshControl {
    private var _isRefreshing:Bool = false
    
    override var isRefreshing: Bool{
        _isRefreshing
    }
    override func beginRefreshing() {
        _isRefreshing = true
    }
    override func endRefreshing() {
        _isRefreshing = false
    }
}

extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach({ (target as NSObject).perform(Selector($0))
            })
        }
    }
}
