//
//  CustomError.swift
//  TripPlanner
//
//  Created by Chris Withers on 3/12/21.
//

import Foundation

enum CustomError: LocalizedError {
    
    case invalidURL
    case thrownError(Error)
    case noData
    case unableToDecode
    case fireBaseError
    
    var errorDescription: String? {
        switch self {
        case .thrownError(let error):
            return "Error: \(error.localizedDescription) -> \(error)"
        case .invalidURL:
            return "Unable to reach the server."
        case .noData:
            return "The server responded with no data."
        case .unableToDecode:
            return "The server responded with bad data."
        case .fireBaseError :
            return "Unable to fulfill request at this time"
        }
    }
}
