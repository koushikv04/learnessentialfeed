//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Kouv on 18/12/2024.
//

import Foundation
import UIKit
import EssentialFeed

public protocol FeedImageDataLoaderTask {
    func cancel()
}



final public class FeedViewController:UITableViewController,UITableViewDataSourcePrefetching {
    private var refreshController:FeedRefreshViewController?
    private var imageLoader:FeedImageLoader?
    private var tableModel = [FeedImage]() {
        didSet {
            tableView.reloadData()
        }
    }
    private var tasks = [IndexPath:FeedImageDataLoaderTask]()
    
    public convenience init(feedLoader: FeedLoader,imageLoader:FeedImageLoader) {
        self.init()
        self.refreshController = FeedRefreshViewController(feedLoader: feedLoader)
        self.imageLoader = imageLoader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = refreshController?.view
        refreshController?.onRefresh =  {[weak self] feed in
            self?.tableModel = feed
            
        }
        self.tableView.prefetchDataSource = self

    }
    
    public override func viewIsAppearing(_ animated: Bool) {
        refreshController?.refresh()
    }

    
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = tableModel[indexPath.row]
        let cell = FeedImageCell()
        cell.locationContainer.isHidden = (model.location == nil)
        cell.locationLabel.text = model.location
        cell.descriptionLabel.text = model.description
        cell.feedImageView.image = nil
        cell.feedImageRetryButton.isHidden = true
        cell.feedImageContainer.startShimmering()
        let loadImage = {[weak self,weak cell] in
            guard let self = self else {return}
            self.tasks[indexPath] = self.imageLoader?.loadImageData(url: model.url) { result in
                let data = try? result.get()
                let image = data.map(UIImage.init) ?? nil
                cell?.feedImageView.image = image
                cell?.feedImageRetryButton.isHidden = (image != nil)
                cell?.feedImageContainer.stopShimmering()
                
            }
        }
        loadImage()
        
        cell.onRetry = loadImage
        return cell
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { index in
            let cellModel = tableModel[index.row]
            tasks[index] = imageLoader?.loadImageData(url: cellModel.url, completion: { _ in
                
            })
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelTask)
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelTask(atRow: indexPath)
    }
    
    private func cancelTask(atRow indexpath:IndexPath) {
        tasks[indexpath]?.cancel()
        tasks[indexpath] = nil
    }
}
