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
    
    var myTrips: [Trip] = []
    
    let db = Firestore.firestore()
    
    func addTrip(trip: Trip?, completion: @escaping(Result<Bool, CustomError>) -> Void) {
        
        let trip = Trip(latitudes: [2.33], longitudes: [1.33], locationNames: ["San Diego", "San Francisco"], members: ["f9@9.com"], name: "Cali Trip", notes: "fun", owner: "f1@1.com", tasks: nil)
        
        
        let batch = self.db.batch()
        
        //New trip to add
        let newTrip = db.collection("trips").document()
        
        //First add non optional values to db, then check for non nil values and add those to the database
        batch.setData(["name" : trip.name, "longitudes" : trip.longitudes, "latitudes" : trip.latitudes, "locationNames" : trip.locationNames, "owner" : trip.owner], forDocument: newTrip)
        
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
    
    func addMember(trip: Trip, member: String, completion: @escaping(Result<Bool, CustomError>) -> Void) {
        var trip = trip
        guard let id = trip.id else { return }
        
        trip.members?.append(member)
        
        let tripFireBase = db.collection("trips").document(id)
        
        tripFireBase.updateData([
            "members" : trip.members
        ]) { (error) in
            if let _ = error {
                return completion(.failure(.fireBaseError))
            } else {
                return completion(.success(true))
            }
        }
        
        
    }
    
    func removeMember(trip: Trip, member: String, completion: @escaping(Result<Bool, CustomError>) -> Void) {
        
        var trip = trip
        guard let id = trip.id else { return completion(.failure(.noData)) }
        
        guard let indexToRemove = trip.members?.firstIndex(of: member) else { return completion(.failure(.noData))}
        
        trip.members?.remove(at: indexToRemove)
        
        let tripFireBase = db.collection("trips").document(id)
        
        tripFireBase.updateData([
            "members" : trip.members
        ]) { (error) in
            if let _ = error {
                return completion(.failure(.fireBaseError))
            } else {
                return completion(.success(true))
            }
        }
        
        
    }
    
    func updateDestination(trip: Trip, destination: Any, completion: @escaping(Result<Bool, CustomError>) -> Void) {
        
    }
    
    func addTask(trip: Trip, task: String, completion: @escaping(Result<Bool, CustomError>) -> Void) {
        
        var trip = trip
        guard let id = trip.id else { return completion(.failure(.noData))}
        
        trip.tasks?.append(task)
        
        let tripFireBase = db.collection("trips").document(id)
        
        tripFireBase.updateData([
            "tasks" : trip.tasks
        ]) { (error) in
            if let _ = error {
                return completion(.failure(.fireBaseError))
            } else {
                return completion(.success(true))
            }
        }
        
    }
    
    func removeTask(trip: Trip, task: String, completion: @escaping(Result<Bool, CustomError>) -> Void) {
        
        var trip = trip
        guard let id = trip.id else { return completion(.failure(.noData))}
        
        guard let indexToRemove = trip.tasks?.firstIndex(of: task) else { return completion(.failure(.noData))}
        
        trip.tasks?.remove(at: indexToRemove)
        
        let tripFireBase = db.collection("trips").document(id)
        
        tripFireBase.updateData([
            "tasks" : trip.tasks
        ]) { (error) in
            if let _ = error {
                return completion(.failure(.fireBaseError))
            } else {
                return completion(.success(true))
            }
        }
        
        
        
    }
    
    func updateName(trip: Trip, name: String, completion: @escaping(Result<Bool, CustomError>) -> Void) {
        
    }
    
    func updateNotes(trip: Trip, notes: String, completion: @escaping(Result<Bool, CustomError>) -> Void) {
        
    }
    
    func fetchMyTrips() {
        
    }
    
    
    
    
}
