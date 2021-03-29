//
//  TPImageView.swift
//  TripPlanner
//
//  Created by Chris Withers on 3/16/21.
//

import UIKit

class TPImageView: UIImageView {

    var placeholderImage = UIImage(named: "defaultAvatar")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        layer.cornerRadius = 10
        clipsToBounds = true
        image = placeholderImage
        translatesAutoresizingMaskIntoConstraints = false
    }

}
