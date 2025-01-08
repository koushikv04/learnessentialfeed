//
//  UIImageView+animation.swift
//  EssentialFeed
//
//  Created by Kouv on 02/01/2025.
//

import UIKit

extension UIImageView {
    
    func animatedImage(_ newImage:UIImage?) {
        image = newImage
        
        guard newImage != nil else {return}
        
        alpha = 0
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
        
        
    }
}
