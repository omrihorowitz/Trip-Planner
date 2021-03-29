//
//  MemberTableViewCell.swift
//  TripPlanner
//
//  Created by Chris Withers on 3/25/21.
//

import UIKit

class MemberTableViewCell: UITableViewCell {

   static let cellID = "CellID"
    
    let profilePhotoImageView = TPImageView(frame: .zero)
    
    let userName = TPTitleLabel(textAlignment: .left, fontSize: 16)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profilePhotoImageView.configure()
    }
    
    func set(user: User) {
        
        userName.text = user.name
        if user.downloadURL != "No" {
            UserController.shared.fetchPhotoForUser(user: user) { [weak self] (result) in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case .success(let image):
                        self.profilePhotoImageView.image = image
                    case .failure(_):
                        break
                    }
                }
            }
        }
        
        
    }
    
    func configure() {
        addSubviews(profilePhotoImageView, userName)
        profilePhotoImageView.tintColor = .black
        
        NSLayoutConstraint.activate([
        
            profilePhotoImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            profilePhotoImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            profilePhotoImageView.heightAnchor.constraint(equalToConstant: 60),
            profilePhotoImageView.widthAnchor.constraint(equalTo: profilePhotoImageView.heightAnchor),
            
            userName.centerYAnchor.constraint(equalTo: profilePhotoImageView.centerYAnchor),
            userName.leadingAnchor.constraint(equalTo: profilePhotoImageView.trailingAnchor, constant: 8),
            
        
        
        ])
        
    }

}
