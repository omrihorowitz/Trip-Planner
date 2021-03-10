//
//  Landmark.swift
//  TripPlanner
//
//  Created by Omri Horowitz on 3/9/21.
//

import Foundation
import MapKit
import Contacts

class Landmark: NSObject, MKAnnotation {
    
  let title: String?
  let neighborhood: String?
  let coordinate: CLLocationCoordinate2D

  init(
    title: String?,
    neighborhood: String?,
    coordinate: CLLocationCoordinate2D
  ) {
    self.title = title
    self.neighborhood = neighborhood
    self.coordinate = coordinate

    super.init()
  }
    init?(feature: MKGeoJSONFeature) {
      // 1
      guard
        let point = feature.geometry.first as? MKPointAnnotation,
        let propertiesData = feature.properties,
        let json = try? JSONSerialization.jsonObject(with: propertiesData),
        let properties = json as? [String: Any]
        else {
          return nil
      }

      // 3
      title = properties["NAME"] as? String
      neighborhood = properties["NEIGHBORHOOD"] as? String
      coordinate = point.coordinate
      super.init()
    }


    var subtitle: String? {
    return neighborhood
  }
    var markerTintColor: UIColor  {
      switch neighborhood {
      case "Downtown":
        return .brown
      case "Pico":
        return .cyan
      case "Ocean Front":
        return .blue
      case "North of Montana":
        return .purple
      case "Ocean Park":
        return .green
      case "Civic Center":
        return .darkGray
      case "Wilshire/Montana":
        return .magenta
      case "Mid-City":
        return .orange
      default:
        return .black
      }
    }
    
    var mapItem: MKMapItem? {
      guard let location = neighborhood else {
        return nil
      }

      let addressDict = [CNPostalAddressStreetKey: location]
      let placemark = MKPlacemark(
        coordinate: coordinate,
        addressDictionary: addressDict)
      let mapItem = MKMapItem(placemark: placemark)
      mapItem.name = title
      return mapItem
    }
    
    var image: UIImage {
      guard let name = neighborhood else {
        return #imageLiteral(resourceName: "Flag")
      }

      switch name {
      case "Downtown":
        return #imageLiteral(resourceName: "icons8-map-pin-50")
      case "Pico":
        return #imageLiteral(resourceName: "icons8-down-button-50")
      case "Ocean Front":
        return #imageLiteral(resourceName: "icons8-bay-50")
      case "North of Montana":
        return #imageLiteral(resourceName: "icons8-map-pin-50-2")
      case "Ocean Park":
        return #imageLiteral(resourceName: "icons8-forest-50")
      case "Civic Center":
        return #imageLiteral(resourceName: "icons8-downtown-50")
      case "Wilshire/Montana":
        return #imageLiteral(resourceName: "icons8-map-50-5")
      case "Mid-City":
        return #imageLiteral(resourceName: "icons8-bus-station-50")
      default:
        return #imageLiteral(resourceName: "icons8-map-pin-50")
      }
    }


}
