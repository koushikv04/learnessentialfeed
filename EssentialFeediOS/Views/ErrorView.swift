//
//  ErrorView.swift
//  EssentialFeed
//
//  Created by Kouv on 02/01/2025.
//

import UIKit

public final class ErrorView: UIView {
    public var message: String? {
        get {
            return isVisible ? label.text : nil
        }
        set {
            setMessageAnimated(newValue)
        }
    }
    @IBOutlet private var label:UILabel!
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        label.text = nil
    }
    
    private var isVisible:Bool {
        return alpha > 0
    }
    
    private func setMessageAnimated(_ message:String?) {
        if let message = message {
            showAnimated(message)
        } else {hideAnimated()}
    }
    
    private func showAnimated(_ message:String) {
        label.text = message
        
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
        
    }
    
    @IBAction private func hideAnimated() {
        UIView.animate(withDuration: 0.25, animations: {self.alpha = 0}) { isCompleted in
            if isCompleted {self.label.text = nil}
        }
    }
}
