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
        
//        let trip = Trip(latitudes: [2.33], longitudes: [1.33], locationNames: ["San Diego", "San Francisco"], members: ["f7@7.com"], name: "Cali Trip", notes: "fun", owner: "f9@9.com", tasks: nil)
        
        
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
        
        var trip = trip
        guard let id = trip.id else { return completion(.failure(.noData))}
        
        trip.name = name
        
        let tripFireBase = db.collection("trips").document(id)
        
        tripFireBase.updateData([
            "name" : trip.name
        ]) { (error) in
            if let _ = error {
                return completion(.failure(.fireBaseError))
            } else {
                return completion(.success(true))
            }
        }
    }
    
    func updateNotes(trip: Trip, notes: String, completion: @escaping(Result<Bool, CustomError>) -> Void) {
        
        var trip = trip
        guard let id = trip.id else { return completion(.failure(.noData))}

        trip.notes = notes
        
        let tripFireBase = db.collection("trips").document(id)
        
        tripFireBase.updateData([
            "notes" : trip.notes
        ]) { (error) in
            if let _ = error {
                return completion(.failure(.fireBaseError))
            } else {
                return completion(.success(true))
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
                let latitudes = data["latitudes"] as? [Float] ?? []
                let longitudes = data["longitudes"] as? [Float] ?? []
                let locationNames = data["locationNames"] as? [String] ?? []
                let owner = data["owner"] as? String ?? ""
                let id = trip.documentID
                let tasks = data["tasks"] as? [String]? ?? nil
                let members = data["members"] as? [String]? ?? nil
                let notes = data["notes"] as? String? ?? nil
                
                let tripToBuild = Trip(latitudes: latitudes, longitudes: longitudes, locationNames: locationNames, members: members, id: id, name: name, notes: notes, owner: owner, tasks: tasks)
                
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

                let tripToBuild = Trip(latitudes: latitudes, longitudes: longitudes, locationNames: locationNames, members: members, id: id, name: name, notes: notes, owner: owner, tasks: tasks)

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
