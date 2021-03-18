//
//  User.swift
//  TripPlanner
//
//  Created by Chris Withers on 3/12/21.
//

import Foundation

struct User : Hashable {
    
    let id: String
    let email: String
    let name: String
    var friends: [String]
    var blocked: [String]
    var pendingSent: [String]
    var pendingReceived: [String]
    var downloadURL: String
    
}
