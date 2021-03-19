//
//  Route.swift
//  TripPlanner
//
//  Created by Omri Horowitz on 3/14/21.
//

import MapKit

struct Route {
  let origin: MKMapItem
  let stops: [MKMapItem]

  var annotations: [MKAnnotation] {
    var annotations: [MKAnnotation] = []

    annotations.append(
      RouteAnnotation(item: origin)
    )
    annotations.append(contentsOf: stops.map { stop in
      return RouteAnnotation(item: stop)
    })

    return annotations
  }
}
