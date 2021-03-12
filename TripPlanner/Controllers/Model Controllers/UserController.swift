//
//  UserController.swift
//  TripPlanner
//
//  Created by Chris Withers on 3/12/21.
//

import Foundation
import Firebase

class UserController {
    
    static var shared = UserController()
    
    let db = Firestore.firestore()
    
    private let storage = Storage.storage().reference()
    
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
        storage.child("images/\(email).png").putData(imageData, metadata: nil) { (_, error) in
            guard error == nil else {
                return completion(.failure(.fireBaseError))
            }
            
            self.storage.child("images/\(email).png").downloadURL { (url, error) in
                
                guard let url = url, error == nil else {
                    return completion(.failure(.invalidURL))
                }
                
                let urlString = url.absoluteString
                return completion(.success(urlString))
            }
        }
    }
    
    
}
