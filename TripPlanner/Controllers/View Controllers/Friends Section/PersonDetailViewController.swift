//
//  PersonDetailViewController.swift
//  TripPlanner
//
//  Created by Chris Withers on 3/12/21.
//

import UIKit

protocol PersonDetailButtonProtocol: AnyObject {
    func buttonSelected(title: String, message: String)
}

class PersonDetailViewController: UIViewController {
    
    let profileImageView = UIImageView()

    let nameLabel = TPTitleLabel(textAlignment: .center, fontSize: 20)
    let friendStatusLabel = TPBodyLabel(textAlignment: .center)
    
    let friendUnfriendButton = TPButton(backgroundColor: .systemGreen, title: "Friend")
    
    let acceptButton = TPButton(backgroundColor: .systemBlue, title: "Accept Friend Request")
    
    let rejectButton = TPButton(backgroundColor: .systemOrange, title: "Reject Friend Request")
    
    let cancelRequestButton = TPButton(backgroundColor: .systemPink, title: "Cancel Sent Request")
    
    let blockUnblockButton = TPButton(backgroundColor: .systemTeal, title: "Block")
    
    let reportButton = TPButton(backgroundColor: .systemYellow, title: "Report")
    
    let buttonStackView = UIStackView(frame: .zero)
    
    var delegate: PersonDetailButtonProtocol?
    
    var user: User? {
        didSet {
            loadViewIfNeeded()
            setUpViewsForUser()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubviews(profileImageView, nameLabel, friendStatusLabel, buttonStackView)
        constrainImageView()
        constrainLabels()
        configureStackView()
        addTargets()
        addCancelKeyboardGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    func addTargets() {
        for button in [friendUnfriendButton, acceptButton, rejectButton, cancelRequestButton, blockUnblockButton, reportButton] {
            button.addTarget(self, action: #selector(actionButtonSelected(sender:)), for: .touchUpInside)
        }
    }
    
    @objc func actionButtonSelected(sender: UIButton) {
        
        guard let user = user else { return }
        
        switch sender {
        
        case friendUnfriendButton:
            
            if friendUnfriendButton.titleLabel?.text == "Friend" {
                UserController.shared.sendFriendRequest(userToFriend: user) { (result) in
                    switch result {
                    case .success(_):
                        self.showMessageAndPopView(title: "Success!", message: "You've sent a friend request!")
                    case .failure(_):
                        self.showMessageAndPopView(title: "Oh no!", message: "Could not send friend request user at this time")
                    }
                }
            }else {
                UserController.shared.unFriendUser(userToUnfriend: user) { (result) in
                    switch result {
                    case .success(_):
                        self.showMessageAndPopView(title: "Success!", message: "You've unfriended this user!")
                    case .failure(_):
                        self.showMessageAndPopView(title: "Oh no!", message: "Could not unfriend user at this time")
                    }
                }
            }
            
        case acceptButton:
            UserController.shared.acceptFriendRequest(userToAccept: user) { (result) in
                switch result {
                case .success(_):
                    self.showMessageAndPopView(title: "Success!", message: "You are now friends!")
                case .failure(_):
                    self.showMessageAndPopView(title: "Oh no!", message: "Could not accept request at this time")
                }
            }
        case rejectButton:
            UserController.shared.declineRequest(userToDecline: user) { (result) in
                switch result {
                case .success(_):
                    self.showMessageAndPopView(title: "Success!", message: "Request declined!")
                case .failure(_):
                    self.showMessageAndPopView(title: "Oh no!", message: "Could not decline request at this time")
                }
            }
        case cancelRequestButton:
            UserController.shared.cancelRequest(userToCancel: user) { (result) in
                switch result {
                case .success(_):
                    self.showMessageAndPopView(title: "Success!", message: "Request cancelled")
                case .failure(_):
                    self.showMessageAndPopView(title: "Oh no!", message: "Could not cancel request at this time")
                }
            }
        case blockUnblockButton:
            
            if blockUnblockButton.titleLabel?.text == "Block" {
                UserController.shared.blockUser(userToBlock: user) { (result) in
                    switch result {
                    case .success(_):
                        self.showMessageAndPopView(title: "Success!", message: "User blocked!")
                    case .failure(_):
                        self.showMessageAndPopView(title: "Oh no!", message: "could not block at this time")
                    }
                }
            } else {
                UserController.shared.unBlockUser(user: user) { (result) in
                    switch result {
                    case .success(_):
                        self.showMessageAndPopView(title: "Success!", message: "User unblocked!")
                    case .failure(_):
                        self.showMessageAndPopView(title: "Oh no!", message: "could not unblock at this time")
                    }
                }
            }
            
            
        case reportButton:
            UserController.shared.reportUser(user: user) { (result) in
                switch result {
                case .success(_):
                    self.showMessageAndPopView(title: "Success!", message: "User reported!")
                case .failure(_):
                    self.showMessageAndPopView(title: "Oh no!", message: "Could not report at this time")
                }
            }
        default:
            break
        }
    }
    
    func showMessageAndPopView(title: String, message: String) {
        delegate?.buttonSelected(title: title, message: message)
        dismiss(animated: true)
    }
    
    func setUpViewsForUser() {
        
        guard let user = user else { return }
        
        guard let currentUser = UserController.shared.currentUser else { return }
        
        //Set name for user
        nameLabel.text = user.name
        
        //Set friend status for user
        if currentUser.friends.contains(user.email) {
            friendStatusLabel.text = "Friend status: Friend"
        } else if currentUser.pendingSent.contains(user.email) {
            friendStatusLabel.text = "Friend status: Pending"
        } else if currentUser.blocked.contains(user.email) {
            friendStatusLabel.text = "Friend status: Blocked"
        } else {
            friendStatusLabel.text = "Friend status: Not friends"
        }
        
        //Set image for user
        if user.downloadURL != "No" {
            UserController.shared.fetchPhotoForUser(user: user) { [weak self] (result) in
                guard let self = self else { return }
                switch result {
                case .success(let image):
                    DispatchQueue.main.async {
                        self.profileImageView.image = image
                    }
                case .failure(_):
                    print("Too bad")
                }
            }
        }
        
        //Sets correct buttons to be visible
        if currentUser.friends.contains(user.email) {
            friendUnfriendButton.set(backgroundColor: .systemGray, title: "Unfriend")
            acceptButton.isHidden = true
            cancelRequestButton.isHidden = true
            rejectButton.isHidden = true
        } else {
            friendUnfriendButton.set(backgroundColor: .systemGreen, title: "Friend")
        }

        if currentUser.pendingReceived.contains(user.email) {
            friendUnfriendButton.isHidden = true
            cancelRequestButton.isHidden = true
            acceptButton.isHidden = false
            rejectButton.isHidden = false
        }
        
        
        if currentUser.pendingSent.contains(user.email) {
            friendUnfriendButton.isHidden = true
            cancelRequestButton.isHidden = false
            acceptButton.isHidden = true
            rejectButton.isHidden = true
        }
        
        if !currentUser.friends.contains(user.email) && !currentUser.pendingSent.contains(user.email) && !currentUser.pendingReceived.contains(user.email) && !user.blocked.contains(currentUser.email) {
            friendUnfriendButton.isHidden = false
            acceptButton.isHidden = true
            rejectButton.isHidden = true
            cancelRequestButton.isHidden = true
            
            if currentUser.blocked.contains(user.email) {
                blockUnblockButton.setTitle("unBlock", for: .normal)
                friendUnfriendButton.isHidden = true
            } else {
                blockUnblockButton.setTitle("Block", for: .normal)
            }
            
        }
        
        if !currentUser.friends.contains(user.email) && !currentUser.pendingSent.contains(user.email) && !currentUser.pendingReceived.contains(user.email) && user.blocked.contains(currentUser.email) {
            
            friendUnfriendButton.isHidden = true
            acceptButton.isHidden = true
            rejectButton.isHidden = true
            cancelRequestButton.isHidden = true
            
            if currentUser.blocked.contains(user.email) {
                blockUnblockButton.setTitle("unBlock", for: .normal)
                friendUnfriendButton.isHidden = true
            } else {
                blockUnblockButton.setTitle("Block", for: .normal)
            }
            
        }
        
        
    }
    
    
    func configureStackView() {
        
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.addArrangedSubview(friendUnfriendButton)
        buttonStackView.addArrangedSubview(acceptButton)
        buttonStackView.addArrangedSubview(rejectButton)
        buttonStackView.addArrangedSubview(cancelRequestButton)
        buttonStackView.addArrangedSubview(blockUnblockButton)
        buttonStackView.addArrangedSubview(reportButton)
        
        buttonStackView.axis = .vertical
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 10
        
        NSLayoutConstraint.activate([
            buttonStackView.topAnchor.constraint(equalTo: view.centerYAnchor),
            buttonStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 50),
            buttonStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -50),
            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        
        
    }
    
    func constrainImageView() {
        
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.image = UIImage(systemName: "person.circle.fill")
        profileImageView.tintColor = .black
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
    
    
    

}
