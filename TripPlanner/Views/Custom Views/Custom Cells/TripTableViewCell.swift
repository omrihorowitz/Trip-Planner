//
//  TripTableViewCell.swift
//  TripPlanner
//
//  Created by Chris Withers on 3/26/21.
//

import UIKit

class TripTableViewCell: UITableViewCell {

    static let cellID = "TripCell"
    
    let ownerImageView = TPImageView(frame: .zero)
    
    let member1ImageView = TPImageView(frame: .zero)
    
    let member2ImageView = TPImageView(frame: .zero)
    
    let tripNameLabel = TPTitleLabel(textAlignment: .left, fontSize:    20)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        constrainCellViewItems()
        makeCircleImageWithBorder()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        ownerImageView.configure()
        member1ImageView.configure()
        member2ImageView.configure()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        makeCircleImageWithBorder()
    }

    func configure(trip: Trip) {
        tripNameLabel.text = trip.name
        tripNameLabel.textColor = Colors.darkBrown
        tripNameLabel.backgroundColor = Colors.lightBrown
        tripNameLabel.textAlignment = .center
        //Find the user object for the owner.
        
        if trip.owner == UserController.shared.currentUser?.email {
            guard let currentUser = UserController.shared.currentUser else {return}
            if currentUser.downloadURL != "No" {
                UserController.shared.fetchPhotoForUser(user: currentUser) { [weak self] (result) in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let image):
                            self.ownerImageView.image = image
                        case .failure(_):
                            break
                        }
                    }
                }
            }
        } else {
            let owner = UserController.shared.users.filter({$0.email == trip.owner})[0]
            
            if owner.downloadURL != "No" {
                UserController.shared.fetchPhotoForUser(user: owner) { [weak self] (result) in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let image):
                            self.ownerImageView.image = image
                        case .failure(_):
                            break
                        }
                    }
                }
            }
        }
        
        setMember1Image(trip: trip)
        setMember2Image(trip: trip)
        
        
    }
    
    func setMember1Image(trip: Trip) {
        
        if let members = trip.members {
            if members.count >= 1 {
                DispatchQueue.main.async {
                    //Make image view not hidden and fetch photo
                    self.member1ImageView.isHidden = false
                    guard let currentUser = UserController.shared.currentUser else { return }
                    if members[0] == currentUser.email {
                        //If owner is the current user
                        UserController.shared.fetchPhotoForUser(user: currentUser) { [weak self] (result) in
                            guard let self = self else { return }
                            DispatchQueue.main.async {
                                switch result {
                                case .success(let image):
                                    self.member1ImageView.image = image
                                case .failure(_):
                                    break
                                }
                            }
                        }
                    } else {
                        //If owner is not current user
                        let member1 = UserController.shared.users.filter({$0.email == members[0]})[0]
                        UserController.shared.fetchPhotoForUser(user: member1) { [weak self] (result) in
                            guard let self = self else { return }
                            DispatchQueue.main.async {
                                switch result {
                                case .success(let image):
                                    self.member1ImageView.image = image
                                case .failure(_):
                                    break
                                }
                            }
                        }
                    }
                }
            } else {
                //Make image view hidden
                DispatchQueue.main.async {
                    self.member1ImageView.isHidden = true
                }
            }
        }
        
        
    }
    
    func setMember2Image(trip: Trip) {
        
        if let members = trip.members {
            if members.count > 1 {
                DispatchQueue.main.async {
                    //Make image view not hidden and fetch photo
                    self.member2ImageView.isHidden = false
                    guard let currentUser = UserController.shared.currentUser else { return }
                    if members[1] == currentUser.email {
                        UserController.shared.fetchPhotoForUser(user: currentUser) { [weak self] (result) in
                            guard let self = self else { return }
                            DispatchQueue.main.async {
                                switch result {
                                case .success(let image):
                                    self.member2ImageView.image = image
                                case .failure(_):
                                    break
                                }
                            }
                        }
                    } else {
                        let member2 = UserController.shared.users.filter({$0.email == members[1]})[0]
                        UserController.shared.fetchPhotoForUser(user: member2) { [weak self] (result) in
                            guard let self = self else { return }
                            DispatchQueue.main.async {
                                switch result {
                                case .success(let image):
                                    self.member2ImageView.image = image
                                case .failure(_):
                                    break
                                }
                            }
                        }
                    }
                }
            } else {
                //Make image view hidden
                DispatchQueue.main.async {
                    self.member2ImageView.isHidden = true
                }
            }
        }
        
        
    }
    
    func constrainCellViewItems() {
        
        self.addSubviews(ownerImageView, member1ImageView, member2ImageView, tripNameLabel)
        
        
        
        
        NSLayoutConstraint.activate([
            ownerImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            ownerImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            ownerImageView.heightAnchor.constraint(equalToConstant: 60),
            ownerImageView.widthAnchor.constraint(equalTo: ownerImageView.heightAnchor),
            
            member1ImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            member1ImageView.leadingAnchor.constraint(equalTo: ownerImageView.centerXAnchor),
            member1ImageView.heightAnchor.constraint(equalToConstant: 60),
            member1ImageView.widthAnchor.constraint(equalTo: member1ImageView.heightAnchor),
            
            member2ImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            member2ImageView.leadingAnchor.constraint(equalTo: member1ImageView.centerXAnchor),
            member2ImageView.heightAnchor.constraint(equalToConstant: 60),
            member2ImageView.widthAnchor.constraint(equalTo: member2ImageView.heightAnchor),
            
            tripNameLabel.leadingAnchor.constraint(equalTo: member2ImageView.trailingAnchor, constant: 8),
            tripNameLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            tripNameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8)
            
        ])
        
        
    }
    
    func makeCircleImageWithBorder() {
        for pic in [ownerImageView, member1ImageView, member2ImageView] {
            pic.tintColor = .black
            pic.layer.cornerRadius = pic.frame.width / 2
            
            pic.layer.masksToBounds = true
            pic.layer.borderWidth = 4
            pic.layer.borderColor = UIColor.white.cgColor
            pic.clipsToBounds = true
            
        }
        ownerImageView.layer.borderColor = UIColor.systemGreen.cgColor
    }
    
}
