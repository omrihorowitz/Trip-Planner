//
//  UserController.swift
//  TripPlanner
//
//  Created by Chris Withers on 3/10/21.
//

import Foundation
import Firebase

class UserController {
    
    static var shared = UserController()
    
    var users: [User] = []
    
    let db = Firestore.firestore()
    
    func fetchAllUsers(completion: @escaping(Result<Bool, Error>) -> Void) {
        
        guard let loggedInEmail = Auth.auth().currentUser?.email else { return }
        
        //
        
        db.collectionGroup("users").whereField("email", isNotEqualTo: loggedInEmail).getDocuments { (users, error) in
            if let error = error {
                print("You have an error \(error.localizedDescription)")
                return completion(.failure(error))
            } else {
                for document in users!.documents {
                    let data = document.data()
                    if let email = data["email"] as? String, let friends = data["friends"] as? [String], let blocked = data["blocked"] as? [String] {
                        let user = User(id: document.documentID, email: email, friends: friends, blocked: blocked)
                        self.users.append(user)
                    } else {
                        print("Couldn't parse")
                    }
                }
                return completion(.success(true))
            }
        }
    }
    
    
}
