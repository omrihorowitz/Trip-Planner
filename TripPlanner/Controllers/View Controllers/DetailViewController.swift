//
//  DetailViewController.swift
//  TripPlanner
//
//  Created by Chris Withers on 3/9/21.
//

import UIKit

class DetailViewController: UIViewController {

    let logoutButton = TPButton(color: .systemRed, title: "Log Out")
    
    let usernameLabel = TPLabel(text: "Username of logged in user")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addSubViews()
        constrainViews()
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
