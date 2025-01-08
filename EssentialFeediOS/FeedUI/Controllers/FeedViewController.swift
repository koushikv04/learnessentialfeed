//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Kouv on 18/12/2024.
//

import Foundation
import UIKit
import EssentialFeed



protocol FeedViewControllerDelegate {
    func didRequestFeedRefresh()
}




final public class FeedViewController:UITableViewController,UITableViewDataSourcePrefetching, FeedLoadingView, FeedErrorView {
    
    
    var delegate:FeedViewControllerDelegate?
    @IBOutlet private(set) public var errorView:ErrorView?
     var tableModel = [FeedImageCellController]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction private func refresh() {
        delegate?.didRequestFeedRefresh()
    }
    
    public override func viewIsAppearing(_ animated: Bool) {
        refresh()
    }

    public func display(_ viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            refreshControl?.beginRefreshing()
        } else {
            refreshControl?.endRefreshing()
        }
    }
    
    public func display(_ viewModel: FeedErrorViewModel) {
        errorView?.message = viewModel.message
    }
    
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellController(forRowAt: indexPath).view(in: tableView)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { index in
            cellController(forRowAt: index).preload()
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelCellControllerLoad)
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelCellControllerLoad(atRow: indexPath)
    }
    
    private func cellController(forRowAt indexpath:IndexPath) -> FeedImageCellController {
        return tableModel[indexpath.row]
       
    }
    
    private func cancelCellControllerLoad(atRow indexpath:IndexPath) {
        cellController(forRowAt: indexpath).cancelLoad()
    }
}
