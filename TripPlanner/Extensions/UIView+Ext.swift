//
//  UIView+Ext.swift
//  TripPlanner
//
//  Created by Chris Withers on 3/12/21.
//

import UIKit

extension UIView {
    
    func addSubviews(_ views: UIView...) {
        for view in views {
            addSubview(view)
        }
    }
    
    func addBorder() {
        layer.borderWidth = 1
        layer.cornerRadius = 3
        layer.borderColor = UIColor.green.cgColor
      }
    
    
}
