//
//  Date+Ext.swift
//  TripPlanner
//
//  Created by Chris Withers on 3/18/21.
//

import Foundation

extension Date {
    
    
    func dateToString() -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: self)
    }
    
}

