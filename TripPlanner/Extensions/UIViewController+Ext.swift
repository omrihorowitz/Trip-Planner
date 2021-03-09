//
//  UIViewController+Ext.swift
//  TripPlanner
//
//  Created by Chris Withers on 3/9/21.
//

import UIKit

extension UIViewController {
    
    func presentAlert(title: String) {
        DispatchQueue.main.async {
            let alert = TPAlertViewController()
            alert.errorMessage = title
            alert.modalPresentationStyle = .overFullScreen
            alert.modalTransitionStyle = .crossDissolve
            self.present(alert, animated: true)
        }
        
    }
    
}
