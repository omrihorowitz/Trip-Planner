//
//  UIButton+Additions.swift
//  TripPlanner
//
//  Created by Omri Horowitz on 3/14/21.
//

import UIKit

extension UIButton {
  func stylize() {
    setTitleColor(.white, for: .normal)
    setBackgroundImage(.buttonBackground, for: .normal)
    titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
    contentEdgeInsets = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
  }
}
