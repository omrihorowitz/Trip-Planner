///
//  UITextField+Additions.swift
//  TripPlanner
//
//  Created by Omri Horowitz on 3/14/21.
//

import UIKit

extension UITextField {
  var contents: String? {
    guard
      let text = text?.trimmingCharacters(in: .whitespaces),
      !text.isEmpty
      else {
        return nil
    }

    return text
  }
}
