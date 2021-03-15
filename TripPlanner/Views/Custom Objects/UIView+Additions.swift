//
//  UIView+Additions.swift
//  TripPlanner
//
//  Created by Omri Horowitz on 3/14/21.
//

import UIKit

extension UIView {
  func addBorder() {
    layer.borderWidth = 1
    layer.cornerRadius = 3
    layer.borderColor = UIColor.green.cgColor
  }
}
