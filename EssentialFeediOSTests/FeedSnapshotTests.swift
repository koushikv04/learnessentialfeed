//
//  FeedSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Kouv on 17/01/2025.
//

import XCTest
import EssentialFeediOS
@testable import EssentialFeed

final class FeedSnapshotTests: XCTestCase {
    
    func test_emptyFeed() {
        let sut = makeSUT()
        sut.display(emptyFeed())
        assert(snapshot:sut.snapshot(for: .iphone8(style: .dark)),named:"EMPTY_FEED_DARK_MODE")
        assert(snapshot:sut.snapshot(for: .iphone8(style: .light)),named:"EMPTY_FEED_LIGHT_MODE")
    }
    
    func test_feedWithContent() {
        let sut = makeSUT()
        sut.display(feedWithContent())
        assert(snapshot:sut.snapshot(for: .iphone8(style: .dark)),named:"FEED_WITH_CONTENT_DARK_MODE")
        assert(snapshot:sut.snapshot(for: .iphone8(style: .light)),named:"FEED_WITH_CONTENT_LIGHT_MODE")
    }
    
    func test_feedWithErrorMessage() {
        let sut = makeSUT()
        sut.display(.error(message: "This is an \nmultiline \nerror message"))
        assert(snapshot: sut.snapshot(for: .iphone8(style: .dark)), named: "FEED_WITH_ERROR_MESSAGE_DARK_MODE")
        assert(snapshot: sut.snapshot(for: .iphone8(style: .light)), named: "FEED_WITH_ERROR_MESSAGE_LIGHT_MODE")
    }
    
    func test_feedWithFailedImageLoading() {
        let sut = makeSUT()
        sut.display(feedWithFailedImageLoading())
        assert(snapshot:sut.snapshot(for: .iphone8(style: .dark)),named:"FEED_WITH_FAILED_IMAGE_LOADING_DARK_MODE")
        assert(snapshot:sut.snapshot(for: .iphone8(style: .light)),named:"FEED_WITH_FAILED_IMAGE_LOADING_LIGHT_MODE")
    }
    
    //MARK: - Helpers
        
    private func makeSUT( file: StaticString = #filePath,
                              line: UInt = #line) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! FeedViewController
        controller.simulateViewAppearing()
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false

        return controller
    }
        
    private func emptyFeed() -> [FeedImageCellController] {
        return []
    }
    
    private func assert(snapshot:UIImage,named name:String, file: StaticString = #filePath,
                        line: UInt = #line) {
        guard let snapshotData = snapshot.pngData() else {
            XCTFail("Failed to get png data representation from snapshot",file: file,line: line)
            return
        }
            
        let snapshotURL = URL(fileURLWithPath: String(describing: file))
                .deletingLastPathComponent()
                .appendingPathComponent("snapshots")
                .appendingPathComponent("\(name).png")
        
        guard let storedSnapshotData = try? Data(contentsOf: snapshotURL) else {
            XCTFail("Failed to convert image to data , first record the image in given url ",file: file,line: line)
            return
        }
         
        
        if snapshotData != storedSnapshotData {
            let temprorarySnapshotURL = URL(fileURLWithPath: NSTemporaryDirectory(),isDirectory: true).appendingPathComponent(snapshotURL.lastPathComponent)
            
            try? snapshotData.write(to: temprorarySnapshotURL)
            
            XCTFail("new snap shot does not match with the stored one New snapshot url \(temprorarySnapshotURL), stored snapshot url \(snapshotURL)",file: file,line: line)
        }
    }
    
    private func record(snapshot:UIImage,named name:String, file: StaticString = #filePath,
                            line: UInt = #line) {
        guard let snapshotData = snapshot.pngData() else {
            XCTFail("Failed to get png data representation from snapshot",file: file,line: line)
            return
        }
            
        let snapshotURL = URL(fileURLWithPath: String(describing: file))
                .deletingLastPathComponent()
                .appendingPathComponent("snapshots")
                .appendingPathComponent("\(name).png")
            
        do {
            try FileManager.default.createDirectory(at: snapshotURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try snapshotData.write(to: snapshotURL)
                
        } catch {
            XCTFail("Failed to record snapshot with error: \(error)",file: file,line: line)
        }
            
            
    }
    
    private func feedWithContent() -> [ImageStub] {
        return [
            ImageStub(
                description: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
                location: "East Side Gallery\nMemorial in Berlin, Germany",
                image: UIImage.make(withColor: .red)
            ),
            ImageStub(
                description: "Garth Pier is a Grade II listed structure in Bangor, Gwynedd, North Wales.",
                location: "Garth Pier",
                image: UIImage.make(withColor: .green)
            )
            
        ]
    }
    
    private func feedWithFailedImageLoading() -> [ImageStub] {
        return [
            ImageStub(description: nil, location: "london", image: nil),ImageStub(description: nil, location: "usa", image: nil)
        ]
    }
    
    
    
    

}

extension UIViewController {
    func snapshot(for configuration:SnapshotConfiguration) -> UIImage {
        return SnapshotWindow(configuration:configuration,root:self).snapshot()
    }
}

struct SnapshotConfiguration {
    let size:CGSize
    let safeAreaInsets:UIEdgeInsets
    let layoutMargins:UIEdgeInsets
    let traitCollection:UITraitCollection
    
    static func iphone8(style:UIUserInterfaceStyle) -> SnapshotConfiguration {
        return SnapshotConfiguration(size: CGSize(width: 375, height: 667), safeAreaInsets: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0), layoutMargins: UIEdgeInsets(top: 20, left: 16, bottom: 0, right: 16), traitCollection: UITraitCollection(traitsFrom: [.init(forceTouchCapability: .available),.init(layoutDirection: .leftToRight),.init(preferredContentSizeCategory: .medium),.init(userInterfaceIdiom: .phone),.init(horizontalSizeClass: .compact),.init(verticalSizeClass: .regular),.init(displayScale: 2),.init(displayGamut: .P3),.init(userInterfaceStyle: style)]))
    }
}


private final class SnapshotWindow:UIWindow {
    private var configuration:SnapshotConfiguration = .iphone8(style: .light)
    
    convenience init(configuration:SnapshotConfiguration, root:UIViewController) {
        
        self.init(frame: CGRect(origin: .zero, size: configuration.size))
        self.configuration = configuration
        self.layoutMargins = configuration.layoutMargins
        self.rootViewController = root
        self.isHidden = false
        root.view.layoutMargins = configuration.layoutMargins
    }
    
    override var safeAreaInsets: UIEdgeInsets {
        return configuration.safeAreaInsets
    }
    
    override var traitCollection: UITraitCollection {
        return UITraitCollection(traitsFrom: [super.traitCollection,configuration.traitCollection])
    }
                                 
    func snapshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds,format: .init(for: traitCollection))
        return renderer.image { action in
            layer.render(in: action.cgContext)
        }
    }
                                 
                                 
}

private extension FeedViewController {
    func display (_ stubs:[ImageStub]) {
        let cellControllers:[FeedImageCellController] = stubs.map { stub in
            let cellController = FeedImageCellController(delegate: stub)
            stub.controller = cellController
            return cellController
        }
        
        display(cellControllers)
    }
    
    func simulateViewAppearing() {
        loadViewIfNeeded()
        beginAppearanceTransition(true, animated: false)
        endAppearanceTransition()
    }
    
    
}

private class ImageStub:FeedImageCellControllerDelegate {
    let viewModel:FeedImageViewModel<UIImage>
    weak var controller:FeedImageCellController?
    
    init(description:String?,location:String?,image:UIImage?) {
        viewModel = FeedImageViewModel(location: location,description: description,image: image, isLoading: false, shouldRetry: image == nil)
    }
    func didRequestImageData() {
        
    }
    
    func didCancelImageRequest() {
        
    }
    
    
}
