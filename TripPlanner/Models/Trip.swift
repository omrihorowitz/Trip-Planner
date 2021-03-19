//
//  Trip.swift
//  TripPlanner
//
//  Created by Chris Withers on 3/17/21.
//

import Foundation

struct Trip {
    var latitudes: [Float]
    var longitudes: [Float]
    var locationNames: [String]
    var members: [String]?
    var id: String?
    var name: String
    var notes: String?
    var owner: String
    var tasks: [String]?
    var startDate: Date
    var endDate: Date
}
