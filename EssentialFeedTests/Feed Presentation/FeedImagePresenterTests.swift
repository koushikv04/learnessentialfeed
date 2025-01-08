//
//  FeedImagePresenterTests.swift
//  EssentialFeed
//
//  Created by Kouv on 02/01/2025.
//

import XCTest
import EssentialFeed


final class FeedImagePresenterTests:XCTestCase {
    
    func test_init_doesNotLoadImageData() {
        let (_,view) = makeSUT()
        XCTAssertTrue(view.messages.isEmpty,"Expected no messages on init")
    }
    
    func test_didStartLoadingImageData_startsLoadingWithNoImage() {
        let (sut,view) = makeSUT()
        let feedImage = uniqueImage()
        sut.didStartLoadingImageData(for:feedImage)
        
        let first = view.messages.first
        XCTAssertEqual(view.messages.count,1)
        XCTAssertEqual(first?.location, feedImage.location)
        XCTAssertEqual(first?.description, feedImage.description)
        XCTAssertEqual(first?.isLoading,true)
        XCTAssertEqual(first?.shouldRetry, false)
        XCTAssertNil(first?.image)
    }
    
    func test_didFinishLoadingImageData_deliversNoImageAndStopsLoading() {
        let (sut,view) = makeSUT()
        let feedImage = uniqueImage()
        let error = anyNSError()
        sut.didFinishLoadingImageData(with: error, for: feedImage)
        
        let first = view.messages.first
        XCTAssertEqual(view.messages.count,1)
        XCTAssertEqual(first?.location, feedImage.location)
        XCTAssertEqual(first?.description, feedImage.description)
        XCTAssertEqual(first?.isLoading,false)
        XCTAssertEqual(first?.shouldRetry, true)
        XCTAssertNil(first?.image)
    }
    
    func test_didFinishLoadingImageData_displaysRetryOnFailedImageTransormation() {
        let (sut,view) = makeSUT(imageTransformer: fail)
        let feedImage = uniqueImage()
        sut.didFinishLoadingImageData(with:Data(),for:feedImage )
        
        let first = view.messages.first
        XCTAssertEqual(view.messages.count,1)
        XCTAssertEqual(first?.location, feedImage.location)
        XCTAssertEqual(first?.description, feedImage.description)
        XCTAssertEqual(first?.isLoading,false)
        XCTAssertEqual(first?.shouldRetry, true)
        XCTAssertNil(first?.image)
    }
    
    func test_didFinishLoadingImageData_displaysImageOnSuccessfulTransformation() {
        let transformedImage = AnyImage()
        let (sut,view) = makeSUT(imageTransformer: {_ in transformedImage})
        let feedImage = uniqueImage()
        sut.didFinishLoadingImageData(with:Data(),for:feedImage )
        
        let first = view.messages.first
        XCTAssertEqual(view.messages.count,1)
        XCTAssertEqual(first?.location, feedImage.location)
        XCTAssertEqual(first?.description, feedImage.description)
        XCTAssertEqual(first?.isLoading,false)
        XCTAssertEqual(first?.shouldRetry, false)
        XCTAssertEqual(first?.image, transformedImage)
    }
    
    //MARK: - Helpers
    private func makeSUT(imageTransformer:@escaping (Data) -> AnyImage? = {_ in nil},file: StaticString = #filePath,
                         line: UInt = #line) -> (sut:FeedImagePresenter<ViewSpy,AnyImage>,view:ViewSpy) {
        let view = ViewSpy()
       let sut = FeedImagePresenter<ViewSpy,AnyImage>(view: view,imageTransformer: imageTransformer)
        trackForMemoryLeaks(view,file: file,line: line)
        trackForMemoryLeaks(sut,file: file,line: line)
        return(sut,view)
        
    }
    
    private struct AnyImage: Equatable {}
    
    private var fail:(Data) -> AnyImage? {
        return {_ in nil}
    }
    
    func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
    private class ViewSpy:FeedImageView {
        
        var messages = [FeedImageViewModel<AnyImage>]()
        
        func display(_ model: FeedImageViewModel<AnyImage>) {
            messages.append(model)
        }
    }
    
}
