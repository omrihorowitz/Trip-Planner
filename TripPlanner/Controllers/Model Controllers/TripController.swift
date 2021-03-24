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
        batch.setData(["name" : trip.name, "originLong" : trip.originLong, "originLat" : trip.originLat, "destinationLong" : trip.destinationLong, "destinationLat" : trip.destinationLat, "owner" : trip.owner, "startDate" : trip.startDate.dateToString(), "endDate" : trip.endDate.dateToString()], forDocument: newTrip)
        
        if let _ = trip.members {
            batch.updateData(["members" : trip.members], forDocument: newTrip)
        }
        
        if let _ = trip.notes {
            batch.updateData(["notes" : trip.notes], forDocument: newTrip)
        }
        
        if let _ = trip.tasks {
            batch.updateData(["tasks" : trip.tasks], forDocument: newTrip)
        }
        
        if let _ = trip.locationNames {
            batch.updateData(["locationNames" : trip.locationNames], forDocument: newTrip)
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
            "originLong" : trip.originLong,
            "originLat" : trip.originLat,
            "destinationLong" : trip.destinationLong,
            "destinationLat" : trip.destinationLat,
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
        
        if let _ = trip.locationNames {
            batch.updateData(["locationNames" : trip.locationNames], forDocument: tripToUpdate)
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
    
    func deleteAllMyTrips(completion: @escaping(Result<Bool, CustomError>) -> Void) {
        
        let batch = self.db.batch()
        
        guard let currentUser = UserController.shared.currentUser?.email else { return completion(.failure(.noData))}
        
        fetchAllTrips { (result) in
            switch result {
            case .success(_):
                for trip in self.allTrips {
                    if trip.owner == currentUser {
                        guard let id = trip.id else { return completion(.failure(.noData))}
                        let tripToDelete = self.db.collection("trips").document(id)
                        batch.deleteDocument(tripToDelete)
                    } else {
                        
                        var trip = trip
                        guard let id = trip.id else { return completion(.failure(.noData))}
                        
                        let tripToUpdate = self.db.collection("trips").document(id)
                        
                        
                        guard let indexOfUser = trip.members?.firstIndex(of: currentUser) else { break }
                        
                        trip.members?.remove(at: indexOfUser)
                        batch.updateData(["members" : trip.members], forDocument: tripToUpdate)
                    }
                }
                batch.commit()
                return completion(.success(true))
            case .failure(_):
                return completion(.failure(.fireBaseError))
            }
        }
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
                let originLong = data["originLong"] as? Double ?? 0.0
                let originLat = data["originLat"] as? Double ?? 0.0
                let destinationLong = data["destinationLong"] as? Double ?? 0.0
                let destinationLat = data["destinationLat"] as? Double ?? 0.0
                let locationNames = data["locationNames"] as? [String] ?? []
                let owner = data["owner"] as? String ?? ""
                let id = trip.documentID
                let tasks = data["tasks"] as? [String]? ?? nil
                let members = data["members"] as? [String]? ?? nil
                let notes = data["notes"] as? String? ?? nil
                let startDate = data["startDate"] as? String ?? nil
                let endDate = data["endDate"] as? String ?? nil
                
                //turn to date and add to trip
                let startDateAsDate = startDate?.stringToDate() ?? Date()
                let endDateAsDate = endDate?.stringToDate() ?? Date()
                
                
                let tripToBuild = Trip(originLong: originLong, originLat: originLat, destinationLong: destinationLong, destinationLat: destinationLat, locationNames: locationNames, members: members, id: id, name: name, notes: notes, owner: owner, tasks: tasks, startDate: startDateAsDate, endDate: endDateAsDate)
                
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
                let originLong = data["originLong"] as? Double ?? 0.0
                let originLat = data["originLat"] as? Double ?? 0.0
                let destinationLong = data["destinationLong"] as? Double ?? 0.0
                let destinationLat = data["destinationLat"] as? Double ?? 0.0
                let locationNames = data["locationNames"] as? [String] ?? []
                let owner = data["owner"] as? String ?? ""
                let id = trip.documentID
                let tasks = data["tasks"] as? [String]? ?? nil
                let members = data["members"] as? [String]? ?? nil
                let notes = data["notes"] as? String? ?? nil
                let startDate = data["startDate"] as? String ?? nil
                let endDate = data["endDate"] as? String ?? nil
                
                //turn to dates and save
                let startDateAsDate = startDate?.stringToDate() ?? Date()
                let endDateAsDate = endDate?.stringToDate() ?? Date()
                
                let tripToBuild = Trip(originLong: originLong, originLat: originLat, destinationLong: destinationLong, destinationLat: destinationLat, locationNames: locationNames, members: members, id: id, name: name, notes: notes, owner: owner, tasks: tasks, startDate: startDateAsDate, endDate: endDateAsDate)

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
    
