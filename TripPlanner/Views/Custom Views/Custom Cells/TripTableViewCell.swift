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
    
    let tripNameLabel = TPTitleLabel(textAlignment: .left, fontSize:    16)
    
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
        print(trip.members)
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
    }
    
}
