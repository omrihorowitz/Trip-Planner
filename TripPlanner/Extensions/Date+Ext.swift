//
//  Date+Ext.swift
//  TripPlanner
//
//  Created by Chris Withers on 3/18/21.
//

import Foundation

extension Date {
    
    
    func dateToString() -> String{
        
        let dateFormatter = ISO8601DateFormatter()

        dateFormatter.formatOptions = [
            .withYear,
            .withMonth,
            .withDay,
            .withTime
        ]
        
        return dateFormatter.string(from: self)

    }
    
    
    
    
    
}

