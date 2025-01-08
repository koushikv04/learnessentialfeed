//
//  FeedImageCellController.swift
//  EssentialFeed
//
//  Created by Kouv on 20/12/2024.
//

import UIKit
import EssentialFeed

protocol FeedImageCellControllerDelegate {
    func didRequestImageData()
    func didCancelImageRequest()
}

final class FeedImageCellController:FeedImageView {
    
    private var delegate:FeedImageCellControllerDelegate
    private  var cell:FeedImageCell?
    
    init(delegate:FeedImageCellControllerDelegate) {
        self.delegate = delegate
    }
    
    func view(in tableView:UITableView) -> UITableViewCell {
        self.cell = tableView.dequeueReusableCell()
        delegate.didRequestImageData()
        return cell!
    }
    
    
    func display(_ model: FeedImageViewModel<UIImage>) {
        cell?.locationLabel.text = model.location
        cell?.descriptionLabel.text = model.description
        cell?.feedImageView.animatedImage(model.image)
        cell?.feedImageContainer.isShimmering = model.isLoading
        cell?.feedImageRetryButton.isHidden = !model.shouldRetry
        cell?.locationContainer.isHidden = !model.hasLocation
        cell?.onRetry = delegate.didRequestImageData
    }
    
    
    
    func preload() {
        delegate.didRequestImageData()
    }
    
    func cancelLoad() {
        releaseCellForReuse()
        delegate.didCancelImageRequest()
    }
    
    private func releaseCellForReuse() {
        cell = nil
    }
}


