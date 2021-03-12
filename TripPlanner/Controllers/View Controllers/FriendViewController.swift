//
//  FriendViewController.swift
//  TripPlanner
//
//  Created by Chris Withers on 3/9/21.
//

import UIKit
import Firebase

class FriendViewController: UIViewController {

    let friendButton = TPButton(color: .systemGreen, title: "Add as friend")
    
    let unfriendButton = TPButton(color: .systemGray, title: "Unfriend")
    
    let blockButton = TPButton(color: .systemPink, title: "Block")
    
    let reportButton = TPButton(color: .systemYellow, title: "Report")
    
    var selectedUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addSubViews()
        constrain()
        addButtonTargets()
    }
  
    @objc func friendButtonTapped() {
        
        guard let selectedUser = selectedUser else { return }
        
        UserController.shared.makeFriend(userToFriend: selectedUser) { (result) in
            switch result {
            case .success(let bool):
                if bool {
                    self.reloadData()
                    self.dismiss(animated: true)
                    self.presentAlert(title: "Friended!")
                    
                } else {
                    self.presentAlert(title: "You are already friends!")
                }
            case .failure(_):
                self.presentAlert(title: "Something went wrong!")
            }
        }
    }
    
    @objc func unfriendButtonTapped() {
        guard let selectedUser = selectedUser else { return }
        
        UserController.shared.unFriend(userToFriend: selectedUser) { (result) in
            switch result {
            case .success(let bool):
                if bool {
                    self.reloadData()
                    self.dismiss(animated: true)
                    self.presentAlert(title: "Unfriended!")
                    
                } else {
                    self.presentAlert(title: "You've already unfriended them!")
                }
            case .failure(_):
                self.presentAlert(title: "Something went wrong!")
            }
        }
    }
    
    
    func addButtonTargets() {
        friendButton.addTarget(self, action: #selector(friendButtonTapped), for: .touchUpInside)
        unfriendButton.addTarget(self, action: #selector(unfriendButtonTapped), for: .touchUpInside)
    }
    
    func reloadData() {
        UserController.shared.fetchAllUsers { (result) in
            switch result {
            case .success(_):
                print("Reloaded data")
            case .failure(_):
                print("Failed to reload data")
            }
        }
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
