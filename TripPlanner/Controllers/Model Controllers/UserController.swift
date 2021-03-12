//
//  UserController.swift
//  TripPlanner
//
//  Created by Chris Withers on 3/10/21.
//

import Foundation
import Firebase

enum CustomError : Error {
    case firebase
}

class UserController {
    
    static var shared = UserController()
    
    var users: [User] = []
    
    var loggedInUser: User?
    
    var friends: [User] = []
    
    let db = Firestore.firestore()
    
    func fetchAllUsers(completion: @escaping(Result<Bool, Error>) -> Void) {
        
        guard let loggedInEmail = Auth.auth().currentUser?.email else { return }
        
        //
        
        self.users = []
        
        db.collectionGroup("users").getDocuments { (users, error) in
            if let error = error {
                print("You have an error \(error.localizedDescription)")
                return completion(.failure(error))
            } else {
                for document in users!.documents {
                    let data = document.data()
                    if let email = data["email"] as? String, let friends = data["friends"] as? [String], let blocked = data["blocked"] as? [String] {
                        let user = User(id: document.documentID, email: email, friends: friends, blocked: blocked)
                        if email == Auth.auth().currentUser?.email {
                            self.loggedInUser = user
                        } else{
                            self.users.append(user)
                        }
                    } else {
                        print("Couldn't parse")
                    }
                }
                return completion(.success(true))
            }
        }
    }
    
    func makeFriend(userToFriend: User, completion: @escaping(Result<Bool, CustomError>)->Void) {
        
        //Checks to make sure they are not already friends
        guard var loggedInUser = loggedInUser else {
            return completion(.failure(.firebase))
        }
        
        var userToFriend = userToFriend
        
        if userToFriend.friends.contains(loggedInUser.email) || loggedInUser.friends.contains(userToFriend.email) {
            return completion(.success(false))
        } else {
            print(userToFriend.friends)
            print(loggedInUser.friends)
        }
        
        //Updates the local structs
        loggedInUser.friends.append(userToFriend.email)
        userToFriend.friends.append(loggedInUser.email)
        
        //Updates the firebase database for first user
        let loggedInUserFireBase = db.collection("users").document(loggedInUser.id)
        
        loggedInUserFireBase.updateData([
            "friends" : loggedInUser.friends
        ]) { (error) in
            if let error = error {
                print(error.localizedDescription)
                return completion(.failure(.firebase))
            } else {
                print("Updated successfully")
                return completion(.success(true))
            }
        }
        
        //Updates the firebase database for second user
        let userToFriendFireBase = db.collection("users").document(userToFriend.id)
    
        userToFriendFireBase.updateData([
            "friends" : userToFriend.friends
        ]) { (error) in
            if let error = error {
                print(error.localizedDescription)
                return completion(.failure(.firebase))
            } else {
                print("Updated successfully")
                return completion(.success(true))
            }
        }
    }
    
    func unFriend(userToFriend: User, completion: @escaping(Result<Bool, CustomError>)->Void) {
        
        //Checks to make sure they are not already friends
        guard var loggedInUser = loggedInUser else {
            return completion(.failure(.firebase))
        }
        
        var userToFriend = userToFriend
        
        if !userToFriend.friends.contains(loggedInUser.email) || !loggedInUser.friends.contains(userToFriend.email) {
            return completion(.success(false))
        }
        
        //Updates the local structs
        guard let userToFriendInLoggedInUsersFriends = loggedInUser.friends.firstIndex(of: userToFriend.email) else { return completion(.failure(.firebase))}
        
        guard let loggedInUserInUserToFriendFriends = userToFriend.friends.firstIndex(of: loggedInUser.email) else { return completion(.failure(.firebase))}
        
        loggedInUser.friends.remove(at: userToFriendInLoggedInUsersFriends)
        userToFriend.friends.remove(at: loggedInUserInUserToFriendFriends)
        
        //Updates the firebase database for first user
        let loggedInUserFireBase = db.collection("users").document(loggedInUser.id)
        
        loggedInUserFireBase.updateData([
            "friends" : loggedInUser.friends
        ]) { (error) in
            if let error = error {
                print(error.localizedDescription)
                return completion(.failure(.firebase))
            } else {
                print("Updated successfully")
                return completion(.success(true))
            }
        }
        
        //Updates the firebase database for second user
        let userToFriendFireBase = db.collection("users").document(userToFriend.id)
    
        userToFriendFireBase.updateData([
            "friends" : userToFriend.friends
        ]) { (error) in
            if let error = error {
                print(error.localizedDescription)
                return completion(.failure(.firebase))
            } else {
                print("Updated successfully")
                return completion(.success(true))
            }
        }
    }
    

    
}
