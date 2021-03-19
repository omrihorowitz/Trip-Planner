//
//  String+Ext.swift
//  TripPlanner
//
//  Created by Chris Withers on 3/18/21.
//

import Foundation

extension String {
    
    func stringToDate() -> Date {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [
            .withYear,
            .withMonth,
            .withDay,
            .withTime
        ]
        let date = isoFormatter.date(from: self)!
        return date
    }
    
}
