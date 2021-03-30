//
//  TPPersonCollectionViewCell.swift
//  TripPlanner
//
//  Created by Chris Withers on 3/16/21.
//

import UIKit

class TPPersonCollectionViewCell: UICollectionViewCell {
    
    static let reuseID = "PersonCell"
    
    var profileImageView = TPImageView(frame: .zero)
    
    let nameLabel = TPTitleLabel(textAlignment: .center, fontSize: 16)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.configure()
    }
    
    override func layoutSubviews() {
        nameLabel.textColor = Colors.darkBlue
        nameLabel.backgroundColor = Colors.brown
    }
    
    func set(user: User) {
        nameLabel.text = user.name
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
    }
    
    private func configure() {
        profileImageView.tintColor = .black
        addSubviews(nameLabel, profileImageView)
        
        let padding: CGFloat = 8
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            profileImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            profileImageView.heightAnchor.constraint(equalTo: profileImageView.widthAnchor),
            
            
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            nameLabel.heightAnchor.constraint(equalToConstant: 20)
        
        ])
    }
    
}
