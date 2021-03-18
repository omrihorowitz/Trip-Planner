//
//  TimeInterval+Additions.swift
//  TripPlanner
//
//  Created by Omri Horowitz on 3/14/21.
//

import Foundation

extension TimeInterval {
  var formatted: String {
    let formatter = DateComponentsFormatter()
    formatter.unitsStyle = .full
    formatter.allowedUnits = [.hour, .minute]

    return formatter.string(from: self) ?? ""
  }
}
