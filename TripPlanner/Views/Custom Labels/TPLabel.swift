//
//  TPLabel.swift
//  TripPlanner
//
//  Created by Omri Horowitz on 3/9/21.
//
import UIKit

class TPLabel: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    convenience init(text: String) {
        self.init(frame: .zero)
        self.text = text // allows it to be changed per label //this needs to be here in convenience init
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        layer.cornerRadius = 20 //curving the radius
        clipsToBounds = true //shows the circle within a square -- need this to play w corners
        translatesAutoresizingMaskIntoConstraints = false //allows programattic constraints
        backgroundColor = .lightGray
        textColor = .purple
        textAlignment = .center //text in the label
        font = UIFont(name:"SanFranciscoDisplay-Thin", size: 40.0) //font type and size
      }
}
