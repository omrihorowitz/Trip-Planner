//
//  CLPlacemark+Additions.swift
//  TripPlanner
//
//  Created by Omri Horowitz on 3/14/21.
//

import CoreLocation

extension CLPlacemark {
  var abbreviation: String {
    if let name = self.name {
      return name
    }

    if let interestingPlace = areasOfInterest?.first {
      return interestingPlace
    }

    return [subThoroughfare, thoroughfare].compactMap { $0 }.joined(separator: " ")
  }
}
