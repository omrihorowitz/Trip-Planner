//
//  PersonDetailViewController.swift
//  TripPlanner
//
//  Created by Chris Withers on 3/12/21.
//

import UIKit

class PersonDetailViewController: UIViewController {
    
    let profileImageView = UIImageView()

    let nameLabel = TPTitleLabel(textAlignment: .center, fontSize: 20)
    let friendStatusLabel = TPBodyLabel(textAlignment: .center)
    
    let friendUnfriendButton = TPButton(backgroundColor: .systemGreen, title: "Friend")
    
    let acceptRejectButton = TPButton(backgroundColor: .systemBlue, title: "Accept Friend Request")
    
    let cancelRequestButton = TPButton(backgroundColor: .systemPink, title: "Cancel Sent Request")
    
    let blockUnblockButton = TPButton(backgroundColor: .systemTeal, title: "Block")
    
    let reportButton = TPButton(backgroundColor: .systemYellow, title: "Report")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubviews(profileImageView, nameLabel, friendStatusLabel, friendUnfriendButton, acceptRejectButton, cancelRequestButton, blockUnblockButton, reportButton)
        constrainImageView()
        constrainLabels()
        constrainButtons()
    }
    
    
    func constrainImageView() {
        
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.image = UIImage(systemName: "person.circle.fill")
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 75),
            profileImageView.heightAnchor.constraint(equalToConstant: 75)
        ])
        
    }
    
    func constrainLabels() {
        
        nameLabel.text = "My name!"
        friendStatusLabel.text = "Friend Status!"
        
        
        NSLayoutConstraint.activate([
        
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        
            friendStatusLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            friendStatusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            friendStatusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        
        ])
        
    }
    
    func constrainButtons() {
        
        NSLayoutConstraint.activate([
        
            reportButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            blockUnblockButton.bottomAnchor.constraint(equalTo: reportButton.topAnchor, constant: -10),
            
            cancelRequestButton.bottomAnchor.constraint(equalTo: blockUnblockButton.topAnchor, constant: -10),
            
            acceptRejectButton.bottomAnchor.constraint(equalTo: cancelRequestButton.topAnchor, constant: -10),
            
            friendUnfriendButton.bottomAnchor.constraint(equalTo: acceptRejectButton.topAnchor, constant: -10),
        
        ])
        
        let buttons = [friendUnfriendButton, cancelRequestButton, acceptRejectButton, reportButton, blockUnblockButton]
        
        for button in buttons {
            NSLayoutConstraint.activate([
                button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
                button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
                button.heightAnchor.constraint(equalToConstant: 50)
            
            ])
        }
        
        
    }
    
    

}
