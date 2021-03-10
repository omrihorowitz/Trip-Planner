//
//  FriendViewController.swift
//  TripPlanner
//
//  Created by Chris Withers on 3/9/21.
//

import UIKit

class FriendViewController: UIViewController {

    let friendButton = TPButton(color: .systemGreen, title: "Add as friend")
    
    let unfriendButton = TPButton(color: .systemGray, title: "Unfriend")
    
    let blockButton = TPButton(color: .systemPink, title: "Block")
    
    let reportButton = TPButton(color: .systemYellow, title: "Report")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addSubViews()
        constrain()
    }
  
    
    func constrain() {
        
        reportButton.setTitleColor(.black, for: .normal)
        
        NSLayoutConstraint.activate([
            friendButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            friendButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            friendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            friendButton.heightAnchor.constraint(equalToConstant: 75),
            
            unfriendButton.topAnchor.constraint(equalTo: friendButton.bottomAnchor, constant: 20),
            unfriendButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            unfriendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            unfriendButton.heightAnchor.constraint(equalToConstant: 75),
            
            blockButton.topAnchor.constraint(equalTo: unfriendButton.bottomAnchor, constant: 20),
            blockButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            blockButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            blockButton.heightAnchor.constraint(equalToConstant: 75),
            
            reportButton.topAnchor.constraint(equalTo: blockButton.bottomAnchor, constant: 20),
            reportButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            reportButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            reportButton.heightAnchor.constraint(equalToConstant: 75)
        
        ])
        
        
    }
    
    
    func addSubViews() {
        view.addSubview(friendButton)
        view.addSubview(unfriendButton)
        view.addSubview(blockButton)
        view.addSubview(reportButton)
    }
    
}
