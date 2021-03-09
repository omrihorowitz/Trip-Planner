//
//  TPTextField.swift
//  TripPlanner
//
//  Created by Chris Withers on 3/9/21.
//

import UIKit

class TPTextField: UITextField {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(placeHolder: String) {
        self.init(frame: .zero)
        placeholder = placeHolder
        layer.cornerRadius = 10
        translatesAutoresizingMaskIntoConstraints = false
    }
    

}
