//
//  TripController.swift
//  TripPlanner
//
//  Created by Chris Withers on 3/17/21.
//

import Foundation
import Firebase

class TripController {
    
    static var shared = TripController()
    
    var tripsIAmOwnerIn: [Trip] = []
    var tripsIBelongTo: [Trip] = []
    
    var allTrips: [Trip] = []
    
    let db = Firestore.firestore()
    
    func addTrip(trip: Trip, completion: @escaping(Result<Bool, CustomError>) -> Void) {
        
        
        let batch = self.db.batch()
        
        //New trip to add
        let newTrip = db.collection("trips").document()
        
        //First add non optional values to db, then check for non nil values and add those to the database
        batch.setData(["name" : trip.name, "longitudes" : trip.longitudes, "latitudes" : trip.latitudes, "locationNames" : trip.locationNames, "owner" : trip.owner, "startDate" : trip.startDate.dateToString(), "endDate" : trip.endDate.dateToString()], forDocument: newTrip)
        
        if let _ = trip.members {
            batch.updateData(["members" : trip.members], forDocument: newTrip)
        }
        
        if let _ = trip.notes {
            batch.updateData(["notes" : trip.notes], forDocument: newTrip)
        }
        
        if let _ = trip.tasks {
            batch.updateData(["tasks" : trip.tasks], forDocument: newTrip)
        }
        
        batch.commit { (error) in
            if let error = error {
                completion(.failure(.fireBaseError))
            } else {
                return completion(.success(true))
            }
        }
    }
    
    func updateTrip(trip: Trip, completion: @escaping(Result<Bool, CustomError>) -> Void) {
        
        guard let id = trip.id else { return }
        
        
        let batch = self.db.batch()
        
        let tripToUpdate = db.collection("trips").document(id)
        
        batch.updateData([
            "name" : trip.name,
            "longitudes" : trip.longitudes,
            "latitudes" : trip.latitudes,
            "locationNames" : trip.locationNames,
            "owner" : trip.owner,
            "startDate" : trip.startDate.dateToString(),
            "endDate" : trip.endDate.dateToString()
        ], forDocument: tripToUpdate)
        
        if let _ = trip.members {
            batch.updateData(["members" : trip.members], forDocument: tripToUpdate)
        }
        
        if let _ = trip.notes {
            batch.updateData(["notes" : trip.notes], forDocument: tripToUpdate)
        }
        
        if let _ = trip.tasks {
            batch.updateData(["tasks" : trip.tasks], forDocument: tripToUpdate)
        }
        
        batch.commit { (error) in
            if let error = error {
                completion(.failure(.fireBaseError))
            } else {
                return completion(.success(true))
            }
        }
    }
    
    func deleteTrip(trip: Trip, completion: @escaping(Result<Bool, CustomError>) -> Void) {
        
       guard let id = trip.id else { return }
        
        db.collection("trips").document(id).delete { (error) in
            if let _ = error {
                print("Too bad")
            } else {
                return completion(.success(true))
            }
        }
        
    }
    
    func updateDestination(trip: Trip, destination: Any, completion: @escaping(Result<Bool, CustomError>) -> Void) {
        
    }

    func fetchMyTrips(completion: @escaping(Result<Bool, CustomError>) -> Void) {
        
        self.tripsIAmOwnerIn = []
        
        let tripFireBase = db.collection("trips")
        
        guard let currentUsersEmail = UserController.shared.currentUser?.email else { return completion(.failure(.noData))}
        
        tripFireBase.whereField("owner", isEqualTo: currentUsersEmail).getDocuments { (trips, error) in
            
            if let _ = error {
                return completion(.failure(.fireBaseError))
            }
            
            for trip in trips!.documents {
                
                let data = trip.data()
                
                let name = data["name"] as? String ?? ""
                let latitudes = data["latitudes"] as? [Float] ?? []
                let longitudes = data["longitudes"] as? [Float] ?? []
                let locationNames = data["locationNames"] as? [String] ?? []
                let owner = data["owner"] as? String ?? ""
                let id = trip.documentID
                let tasks = data["tasks"] as? [String]? ?? nil
                let members = data["members"] as? [String]? ?? nil
                let notes = data["notes"] as? String? ?? nil
                let startDate = data["startDate"] as? String ?? nil
                let endDate = data["endDate"] as? String ?? nil
                
                //turn to date and add to trip
                let startDateAsDate = startDate?.convertToDate() ?? Date()
                let endDateAsDate = endDate?.convertToDate() ?? Date()
                
                
                let tripToBuild = Trip(latitudes: latitudes, longitudes: longitudes, locationNames: locationNames, members: members, id: id, name: name, notes: notes, owner: owner, tasks: tasks, startDate: startDateAsDate, endDate: endDateAsDate)
                
                self.tripsIAmOwnerIn.append(tripToBuild)
                
            }
            return completion(.success(true))
        }
        
    }
    
    func fetchTripsIBelongTo(completion: @escaping(Result<Bool, CustomError>) -> Void) {
        
        self.tripsIBelongTo = []
        
        let tripFireBase = db.collection("trips")
        
        guard let currentUsersEmail = UserController.shared.currentUser?.email else { return completion(.failure(.noData))}
        
        tripFireBase.whereField("members", arrayContains: currentUsersEmail).getDocuments { (trips, error) in

            if let _ = error {
                return completion(.failure(.fireBaseError))
            }

            for trip in trips!.documents {

                let data = trip.data()

                let name = data["name"] as? String ?? ""
                let latitudes = data["latitudes"] as? [Float] ?? []
                let longitudes = data["longitudes"] as? [Float] ?? []
                let locationNames = data["locationNames"] as? [String] ?? []
                let owner = data["owner"] as? String ?? ""
                let id = trip.documentID
                let tasks = data["tasks"] as? [String]? ?? nil
                let members = data["members"] as? [String]? ?? nil
                let notes = data["notes"] as? String? ?? nil
                let startDate = data["startDate"] as? String ?? nil
                let endDate = data["endDate"] as? String ?? nil
                
                //turn to dates and save
                let startDateAsDate = startDate?.convertToDate() ?? Date()
                let endDateAsDate = endDate?.convertToDate() ?? Date()
                
                let tripToBuild = Trip(latitudes: latitudes, longitudes: longitudes, locationNames: locationNames, members: members, id: id, name: name, notes: notes, owner: owner, tasks: tasks, startDate: startDateAsDate, endDate: endDateAsDate)

                self.tripsIBelongTo.append(tripToBuild)

            }
            self.allTrips = self.tripsIAmOwnerIn + self.tripsIBelongTo
            return completion(.success(true))
        }
    }
    
    func fetchAllTrips(completion: @escaping(Result<Bool, CustomError>) -> Void) {
        
        fetchMyTrips { (result) in
            switch result {
            case .success(_):
                self.fetchTripsIBelongTo { (result) in
                    switch result {
                    case .success(_):
                        return completion(.success(true))
                    case .failure(let error):
                        print(error.localizedDescription)
                        return completion(.failure(.fireBaseError))
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
                return completion(.failure(.fireBaseError))
            }
        }
    }
    
}
    
