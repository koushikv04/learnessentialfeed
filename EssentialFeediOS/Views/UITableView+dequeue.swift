//
//  UITableView+dequeue.swift
//  EssentialFeed
//
//  Created by Kouv on 02/01/2025.
//

import UIKit
extension UITableView {
    func dequeueReusableCell<T:UITableViewCell>() -> T {
        let cellName = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: cellName) as! T
    }
}
