//
//  UserController.swift
//  TripPlanner
//
//  Created by Chris Withers on 3/12/21.
//

import Foundation
import Firebase

protocol FireBaseUpdatedDelegate: AnyObject {
    
    func updateCollectionView()
    
}

class UserController {
    
    static var shared = UserController()
    
    let db = Firestore.firestore()
    
    private let storage = Storage.storage().reference()
    
    let cache = NSCache<NSString, UIImage>()
    
    var currentUser: User?
    
    var delegate: FireBaseUpdatedDelegate?
    
    var users: [User] = []
    
    var friends: [User] = []
    
    var sent: [User] = []
    
    var received: [User] = []
    
    var addable: [User] = []
    
    var blocked: [User] = []
    
    var filtered: [User] = []
    
    func createUserInDB(email: String, name: String, downloadURL: String?) {
        
        guard let id = Auth.auth().currentUser?.uid else { return }
        // create new user in db with that id, and email and empty lists
        let downloadURL = downloadURL ?? "No"
        
        db.collection("users").document(id).setData([
            "name" : name,
            "email": email,
            "blocked": [],
            "friends": [],
            "pendingSent": [],
            "pendingReceived": [],
            "downloadURL" : downloadURL
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    func uploadPhotoForUser(imageData: Data, email: String, completion: @escaping(Result<String, CustomError>) -> Void) {
        
        storage.child("images/\(email.lowercased()).jpg").putData(imageData, metadata: nil) { (_, error) in
            guard error == nil else {
                return completion(.failure(.fireBaseError))
            }
            
            self.storage.child("images/\(email).jpg").downloadURL { (url, error) in
                
                guard let url = url, error == nil else {
                    return completion(.failure(.invalidURL))
                }
                
                let urlString = url.absoluteString
                return completion(.success(urlString))
            }
        }
    }
    
    func fetchPhotoForUser(user: User, completion: @escaping(Result<UIImage, CustomError>) -> Void ) {
        
        if let image = cache.object(forKey: user.downloadURL as NSString) {
            completion(.success(image))
            return
        }
        
        guard let downloadURL = URL(string: user.downloadURL) else { return completion(.failure(.invalidURL))}
        
        
        
        URLSession.shared.dataTask(with: downloadURL) { (data, _, error) in
            if let _ = error {
                return completion(.failure(.fireBaseError))
            }
            
            if let data = data {
                guard let userImage = UIImage(data: data) else { return completion(.failure(.noData))}
                self.cache.setObject(userImage, forKey: user.downloadURL as NSString)
                return completion(.success(userImage))
            }
            
        }.resume()
        
    }
    
    func fetchAllUsers(completion: @escaping(Result<Bool, Error>) -> Void) {
           
           guard let loggedInEmail = Auth.auth().currentUser?.email else { return }
           
           //
           
          
           
           db.collectionGroup("users").addSnapshotListener { (users, error) in
               self.users = []
               if let error = error {
                   print("You have an error \(error.localizedDescription)")
                   return completion(.failure(error))
               } else {
                   for document in users!.documents {
                       let data = document.data()
                       if let email = data["email"] as? String, let name = data["name"] as? String, let friends = data["friends"] as? [String], let blocked = data["blocked"] as? [String],
                          let pendingSent = data["pendingSent"] as? [String], let pendingReceived = data["pendingReceived"] as? [String], let downloadURL = data["downloadURL"] as? String {
                        let user = User(id: document.documentID, email: email, name: name, friends: friends, blocked: blocked, pendingSent: pendingSent, pendingReceived: pendingReceived, downloadURL: downloadURL)
                           if email == loggedInEmail {
                               self.currentUser = user
                           } else{
                               self.users.append(user)
                           }
                       } else {
                           print("Couldn't parse")
                       }
                   }
                self.delegate?.updateCollectionView()
                   return completion(.success(true))
               }
           }
       }
    
    func fetchFriends() {
        guard let currentUser = currentUser else {return}
        
        self.friends = self.users.filter({(currentUser.friends.contains($0.email))})
    }
    
    func fetchSent() {
        guard let currentUser = currentUser else {return}
        
        self.sent = self.users.filter({(currentUser.pendingSent.contains($0.email))})
    }
    
    func fetchReceived() {
        guard let currentUser = currentUser else {return}
        
        self.received = self.users.filter({(currentUser.pendingReceived.contains($0.email))})
    }
    
    func fetchAddable() {
        
        guard let currentUser = currentUser else {return}
        
        self.addable = self.users.filter({!currentUser.friends.contains($0.email) && !currentUser.pendingSent.contains($0.email) && !currentUser.pendingReceived.contains($0.email)})
        
    }
    
    func fetchBlocked() {
        guard let currentUser = currentUser else {return}
        
        self.blocked = self.users.filter({(currentUser.blocked.contains($0.email))})
    }
    
    func filterList(list: [User], searchTerm: String) {
        
        filtered = []
        
        for user in list {
            if user.name.lowercased().contains(searchTerm.lowercased()) {
                filtered.append(user)
            }
        }
    }
    
    
    
    func sendFriendRequest(userToFriend: User, completion: @escaping(Result<Bool, CustomError>) -> Void) {
        
        guard var currentUser = currentUser else {
            return completion(.failure(.noData))
        }
        
        var userToFriend = userToFriend
        
        userToFriend.pendingReceived.append(currentUser.email)
        currentUser.pendingSent.append(userToFriend.email)
        
        let currentUserFireBase = db.collection("users").document(currentUser.id)
        
        currentUserFireBase.updateData([
            "pendingSent" : currentUser.pendingSent
        ]) { (error) in
            if let _ = error {
                return completion(.failure(.fireBaseError))
            } else {
                //completion(.success(true))
            }
        }
        
        let userToFriendFireBase = db.collection("users").document(userToFriend.id)
        
        userToFriendFireBase.updateData([
            "pendingReceived" : userToFriend.pendingReceived
        ]) { (error) in
            if let _ = error {
                return completion(.failure(.fireBaseError))
            } else {
                return completion(.success(true))
            }
        }
        
    }
    
    func cancelRequest(userToCancel: User, completion: @escaping(Result<Bool, CustomError>) -> Void) {
        
        guard var currentUser = currentUser else {
            return completion(.failure(.fireBaseError))
        }
        
        var userToCancel = userToCancel
        
        guard let indexOfCurrentUser = userToCancel.pendingReceived.firstIndex(of: currentUser.email) else { return completion(.failure(.fireBaseError))}
        
        guard let indexOfUserToCancel = currentUser.pendingSent.firstIndex(of: userToCancel.email) else { return completion(.failure(.fireBaseError))}
        
        currentUser.pendingSent.remove(at: indexOfUserToCancel)
        userToCancel.pendingReceived.remove(at: indexOfCurrentUser)
        
        let CurrentUserFireBase = db.collection("users").document(currentUser.id)
        
        CurrentUserFireBase.updateData([
            "pendingSent" : currentUser.pendingSent
        ]) { (error) in
            if let _ = error {
                return completion(.failure(.fireBaseError))
            } else {
                //completion(.success(true))
            }
        }
        
        let userToUnfriendFireBase = db.collection("users").document(userToCancel.id)
        
        userToUnfriendFireBase.updateData([
            "pendingReceived" : userToCancel.pendingReceived
        ]) { (error) in
            if let _ = error {
                return completion(.failure(.fireBaseError))
            } else {
                return completion(.success(true))
            }
        }
    }
    
    func declineRequest(userToDecline: User, completion: @escaping(Result<Bool, CustomError>) -> Void) {
        
        guard var currentUser = currentUser else {
            return completion(.failure(.fireBaseError))
        }
        
        var userToDecline = userToDecline
        
        guard let indexOfCurrentUser = userToDecline.pendingSent.firstIndex(of: currentUser.email) else { return completion(.failure(.fireBaseError))}
        
        guard let indexOfUserToCancel = currentUser.pendingReceived.firstIndex(of: userToDecline.email) else { return completion(.failure(.fireBaseError))}
        
        currentUser.pendingReceived.remove(at: indexOfUserToCancel)
        userToDecline.pendingSent.remove(at: indexOfCurrentUser)
        
        let CurrentUserFireBase = db.collection("users").document(currentUser.id)
        
        CurrentUserFireBase.updateData([
            "pendingReceived" : currentUser.pendingReceived
        ]) { (error) in
            if let _ = error {
                return completion(.failure(.fireBaseError))
            } else {
                //completion(.success(true))
            }
        }
        
        let userToUnfriendFireBase = db.collection("users").document(userToDecline.id)
        
        userToUnfriendFireBase.updateData([
            "pendingSent" : userToDecline.pendingSent
        ]) { (error) in
            if let _ = error {
                return completion(.failure(.fireBaseError))
            } else {
                return completion(.success(true))
            }
        }
        
    }
    
    func acceptFriendRequest(userToAccept: User, completion: @escaping(Result<Bool, CustomError>) -> Void) {
        
        //Checks we have logged in user
        guard var currentUser = currentUser else {
            return completion(.failure(.fireBaseError))
        }
        
        var userToAccept = userToAccept
        
        
        guard let indexOfUserToAcceptsEmailInCurrentUsersReceived = currentUser.pendingReceived.firstIndex(of: userToAccept.email) else { return completion(.failure(.fireBaseError))}
        
        guard let indexOfCurrentUsersEmailInUserToAcceptsSent = userToAccept.pendingSent.firstIndex(of: currentUser.email) else { return completion(.failure(.fireBaseError))}
        
        currentUser.pendingReceived.remove(at: indexOfUserToAcceptsEmailInCurrentUsersReceived)
        
        userToAccept.pendingSent.remove(at: indexOfCurrentUsersEmailInUserToAcceptsSent)
        
        currentUser.friends.append(userToAccept.email)
        userToAccept.friends.append(currentUser.email)
        
        let CurrentUserFireBase = db.collection("users").document(currentUser.id)
        
        CurrentUserFireBase.updateData([
            "friends" : currentUser.friends,
            "pendingReceived" : currentUser.pendingReceived
        ]) { (error) in
            if let _ = error {
                return completion(.failure(.fireBaseError))
            } else {
                //completion(.success(true))
            }
        }
        
        let userToAcceptFirebase = db.collection("users").document(userToAccept.id)
        
        userToAcceptFirebase.updateData([
            "friends" : userToAccept.friends,
            "pendingSent" : userToAccept.pendingSent
        ]) { (error) in
            if let _ = error {
                return completion(.failure(.fireBaseError))
            } else {
                return completion(.success(true))
            }
        }
        
    }
    
    func unFriendUser(userToUnfriend: User, completion: @escaping(Result<Bool, CustomError>) -> Void) {
        
        guard var currentUser = currentUser else {
            return completion(.failure(.fireBaseError))
        }
        
        var userToUnfriend = userToUnfriend
        
        guard let indexOfCurrentUser = userToUnfriend.friends.firstIndex(of: currentUser.email) else { return completion(.failure(.fireBaseError))}
        
        guard let indexOfUserToUnfriend = currentUser.friends.firstIndex(of: userToUnfriend.email) else { return completion(.failure(.fireBaseError))}
        
        currentUser.friends.remove(at: indexOfUserToUnfriend)
        userToUnfriend.friends.remove(at: indexOfCurrentUser)
        
        let CurrentUserFireBase = db.collection("users").document(currentUser.id)
        
        CurrentUserFireBase.updateData([
            "friends" : currentUser.friends
        ]) { (error) in
            if let _ = error {
                return completion(.failure(.fireBaseError))
            } else {
                //completion(.success(true))
            }
        }
        
        let userToUnfriendFireBase = db.collection("users").document(userToUnfriend.id)
        
        userToUnfriendFireBase.updateData([
            "friends" : userToUnfriend.friends
        ]) { [weak self] (error) in
            guard let self = self else { return }
            if let _ = error {
                return completion(.failure(.fireBaseError))
            } else {
                self.removeUnfriendedPersonFromTrips(userToRemove: userToUnfriend)
                return completion(.success(true))
            }
        }
    }
    
    func removeUnfriendedPersonFromTrips(userToRemove: User) {
        
        let batch = self.db.batch()
        
        //Call fetch trips I own
        TripController.shared.fetchMyTrips { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(_):
                for trip in TripController.shared.tripsIAmOwnerIn {
                    guard let id = trip.id else { return }
                    let currentTrip = self.db.collection("trips").document(id)
                    if var members = trip.members {
                        if members.contains(userToRemove.email) {
                            guard let indexToRemove = members.firstIndex(of: userToRemove.email) else {
                                return
                            }
                            members.remove(at: indexToRemove)
                            batch.updateData(["members" : members], forDocument: currentTrip)
                        }
                    }
                    
                }
                batch.commit()
            case .failure(_):
                break
            }
        }
        
        
        
        
        
    }
    
    func blockUser(userToBlock: User, completion: @escaping(Result<Bool, CustomError>) -> Void) {
        
        guard var currentUser = currentUser else {
            return completion(.failure(.fireBaseError))
        }
        
        currentUser.blocked.append(userToBlock.email)
        
        if currentUser.friends.contains(userToBlock.email) {
            unFriendUser(userToUnfriend: userToBlock) { (result) in
                switch result {
                case .success(_):
                    print("Unfriended")
                case .failure(_):
                    print("can't unfriend")
                }
            }
        }
        
        if currentUser.pendingSent.contains(userToBlock.email) {
            cancelRequest(userToCancel: userToBlock) { (result) in
                switch result {
                case .success(_):
                    print("Cancelled request")
                case .failure(_):
                    print("Can't cancel request")
                }
            }
        }
        
        if currentUser.pendingReceived.contains(userToBlock.email) {
            declineRequest(userToDecline: userToBlock) { (result) in
                switch result {
                case .success(_):
                    print("Declined request")
                case .failure(_):
                    print("Can't decline request")
                }
            }
        }
        
        
        let CurrentUserFireBase = db.collection("users").document(currentUser.id)
        
        CurrentUserFireBase.updateData([
            "blocked" : currentUser.blocked
        ]) { (error) in
            if let _ = error {
                return completion(.failure(.fireBaseError))
            } else {
                return completion(.success(true))
            }
        }
    }
    
    func unBlockUser(user: User, completion: @escaping(Result<Bool, CustomError>) -> Void) {
        
        guard var currentUser = currentUser else {
            return completion(.failure(.fireBaseError))
        }
        
        currentUser.blocked.removeAll(where: {$0 == user.email})
        
        let CurrentUserFireBase = db.collection("users").document(currentUser.id)
        
        CurrentUserFireBase.updateData([
            "blocked" : currentUser.blocked
        ]) { (error) in
            if let _ = error {
                return completion(.failure(.fireBaseError))
            } else {
                return completion(.success(true))
            }
        }
    }
    
    func reportUser(user: User, completion: @escaping(Result<Bool, CustomError>) -> Void) {
        
        db.collection("reported").document(user.email).setData([
            "email" : user.email
        ]) { err in
            if let _ = err {
                return completion(.failure(.fireBaseError))
            } else {
                return completion(.success(true))
            }
        }
    }
    
    func removeAllReferences(completion: @escaping(Result<Bool, CustomError>) -> Void) {
        
        let batch = self.db.batch()
        
        guard let currentUser = UserController.shared.currentUser?.email else { return completion(.failure(.noData))}
        
        for user in users {
            
            var user = user
            
            let userToUpdate = db.collection("users").document(user.id)
            
            if user.blocked.contains(currentUser) {
                guard let indexOfUser = user.blocked.firstIndex(of: currentUser) else { return  completion(.failure(.noData)) }
                user.blocked.remove(at: indexOfUser)
                batch.updateData(["blocked" : user.blocked], forDocument: userToUpdate)
            }
            
            if user.friends.contains(currentUser) {
                guard let indexOfUser = user.friends.firstIndex(of: currentUser) else { return  completion(.failure(.noData)) }
                user.friends.remove(at: indexOfUser)
                batch.updateData(["friends" : user.friends], forDocument: userToUpdate)
            }
            
            if user.pendingSent.contains(currentUser) {
                guard let indexOfUser = user.pendingSent.firstIndex(of: currentUser) else { return  completion(.failure(.noData)) }
                user.pendingSent.remove(at: indexOfUser)
                batch.updateData(["pendingSent" : user.pendingSent], forDocument: userToUpdate)
            }
            
            if user.pendingReceived.contains(currentUser) {
                guard let indexOfUser = user.pendingReceived.firstIndex(of: currentUser) else { return  completion(.failure(.noData)) }
                user.pendingReceived.remove(at: indexOfUser)
                batch.updateData(["pendingReceived" : user.pendingReceived], forDocument: userToUpdate)
            }
            
        }
        batch.commit { (error) in
            if let _ = error {
                return completion(.failure(.fireBaseError))
            }
            return completion(.success(true))
        }
    }
    
    func removePhotoInCloud(completion: @escaping(Result<Bool, CustomError>) -> Void) {
        
        guard let currentUser = UserController.shared.currentUser?.email else { return }
        
        if UserController.shared.currentUser?.downloadURL != "No" {
            let picStorage = storage.child("images/\(currentUser).jpg")
            
            picStorage.delete { (error) in
                if let _ = error {
                    return completion(.failure(.fireBaseError))
                }
                return completion(.success(true))
            }
        }
    }
    
    func removeUserFromDatabase(completion: @escaping(Result<Bool, CustomError>) -> Void) {
        
        guard let currentUser = UserController.shared.currentUser else { return }
        
        let userFireBase = db.collection("users").document(currentUser.id)
        
        userFireBase.delete { (error) in
            if let _ = error {
                return completion(.failure(.fireBaseError))
            }
            return completion(.success(true))
        }
        
    }
    
    func deleteAccount(completion: @escaping(Result<Bool, CustomError>) -> Void) {
        TripController.shared.deleteAllMyTrips() { (result) in
            switch result {
            case .success(_):
                UserController.shared.removeAllReferences { (result) in
                    switch result {
                    case .success(_):
                        print("Removed all trips and references")
                        
                        UserController.shared.removePhotoInCloud { (result) in
                            switch result {
                            case .success(_):
                                print("Done")
                            case .failure(_):
                                print("Error")
                            }
                        }
                        
                        self.removeUserFromDatabase { (result) in
                            
                            switch result {
                            case .success(_):
                                
                                let currentUser = Auth.auth().currentUser
                                
                                currentUser?.delete(completion: { (error) in
                                    if let _ = error {
                                        return completion(.failure(.fireBaseError))
                                    }
                                    return completion(.success(true))
                                })
                                
                            case .failure(_):
                                return completion(.failure(.fireBaseError))
                            }
                        }
                    case .failure(_):
                        return completion(.failure(.fireBaseError))
                    }
                }
            case .failure(_):
                return completion(.failure(.fireBaseError))
            }
        }
    }
    
    func updateName(user: User?, completion: @escaping(Result<Bool, CustomError>) -> Void) {
        
        guard let currentUser = UserController.shared.currentUser else { return }
        
        let userFireBase = db.collection("users").document(currentUser.id)
        
        userFireBase.updateData([
            "name" : currentUser.name
        ]) { (error) in
            if let _ = error {
                return completion(.failure(.fireBaseError))
            }
            return completion(.success(true))
        }
    }
    
    func someoneHasBlockedThisPerson(personToCheck: User, membersInTrip: [String]) -> Bool {
        
        let membersInTripAsUsers = friends.filter({membersInTrip.contains($0.email)})
        
        return membersInTripAsUsers.filter({$0.blocked.contains(personToCheck.email)}).count >= 1
    }
    
}
    

