//
//  DetailViewController.swift
//  TripPlanner
//
//  Created by Chris Withers on 3/9/21.
//

import UIKit
import Firebase

class DetailViewController: UIViewController {

    let logoutButton = TPButton(color: .systemRed, title: "Log Out")
    
    let usernameLabel = TPLabel(text: "Username of logged in user")
    
    var email: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addSubViews()
        constrainViews()
        logoutButton.addTarget(self, action: #selector(logout), for: .touchUpInside)
        usernameLabel.text = email
    }
    
    @objc func logout() {
        do {
            try Auth.auth().signOut()
            dismiss(animated: true)
        } catch let signoutError as NSError {
            self.presentAlert(title: signoutError.localizedDescription)
        }
    }
    
    func addSubViews() {
        view.addSubview(usernameLabel)
        view.addSubview(logoutButton)
    }
    
    func constrainViews() {
        
        NSLayoutConstraint.activate([
            usernameLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            usernameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            usernameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            usernameLabel.heightAnchor.constraint(equalToConstant: 50),
            
            logoutButton.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 50),
            logoutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            logoutButton.heightAnchor.constraint(equalToConstant: 75)
        ])
        
        
    }
    
    

}
