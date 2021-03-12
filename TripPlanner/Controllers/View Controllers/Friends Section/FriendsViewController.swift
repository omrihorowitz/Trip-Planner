//
//  FriendsViewController.swift
//  TripPlanner
//
//  Created by Chris Withers on 3/12/21.
//

import UIKit
import Firebase

class FriendsViewController: UIViewController {

    let logoutButton = TPButton(backgroundColor: .systemPink, title: "Logout")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(logoutButton)
        constrainLogout()
        
        logoutButton.addTarget(self, action: #selector(logout), for: .touchUpInside)
    }
    
    
    @objc func logout() {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signoutError as NSError {
            self.presentAlertOnMainThread(title: "Uh oh", message: signoutError.localizedDescription, buttonTitle: "Ok")
        }
    }
    
    func constrainLogout() {
        NSLayoutConstraint.activate([
            logoutButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logoutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            logoutButton.heightAnchor.constraint(equalToConstant: 75)
        ])
    }

}
