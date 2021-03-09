//
//  TPLabel.swift
//  TripPlanner
//
//  Created by Chris Withers on 3/9/21.
//

import UIKit

class TPLabel: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(text: String) {
        self.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        self.text = text
        textAlignment = .center
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
