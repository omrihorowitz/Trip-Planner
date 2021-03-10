//
//  LandmarkViews.swift
//  TripPlanner
//
//  Created by Omri Horowitz on 3/9/21.
//

import MapKit

class LandmarkMarkerView: MKMarkerAnnotationView {
  override var annotation: MKAnnotation? {
    willSet {
      // 1
        guard let landmark = newValue as? Landmark else {
        return
      }
      canShowCallout = true
      calloutOffset = CGPoint(x: -5, y: 5)
      rightCalloutAccessoryView = UIButton(type: .detailDisclosure)

      // 2
      markerTintColor = landmark.markerTintColor
      glyphImage = landmark.image
        
        let detailLabel = UILabel()
        detailLabel.numberOfLines = 0
        detailLabel.font = detailLabel.font.withSize(12)
        detailLabel.text = landmark.subtitle
        detailCalloutAccessoryView = detailLabel

      }
    }
}

class LandmarkView: MKAnnotationView {
  override var annotation: MKAnnotation? {
    willSet {
        guard let landmark = newValue as? Landmark else {
        return
      }

      canShowCallout = true
      calloutOffset = CGPoint(x: -5, y: 5)
        let mapsButton = UIButton(frame: CGRect(
          origin: CGPoint.zero,
          size: CGSize(width: 48, height: 48)))
        mapsButton.setBackgroundImage(#imageLiteral(resourceName: "icons8-maps-50"), for: .normal)
        rightCalloutAccessoryView = mapsButton
      image = landmark.image
    }
  }
}
