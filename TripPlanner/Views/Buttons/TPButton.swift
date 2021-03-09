//
//  TPButton.swift
//  TripPlanner
//
//  Created by Chris Withers on 3/9/21.
//

import UIKit

class TPButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(color: UIColor, title: String) {
        self.init(frame: .zero)
        backgroundColor = color
        setTitle(title, for: .normal)
    }
    
    func configure() {
        layer.cornerRadius = 10
        translatesAutoresizingMaskIntoConstraints = false
    }

}
