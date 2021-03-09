//
//  TPAlertViewController.swift
//  TripPlanner
//
//  Created by Chris Withers on 3/9/21.
//

import UIKit

class TPAlertViewController: UIViewController {

    var errorMessage: String = "Alert"
    
    let alertLabel = TPLabel(text: "")
    let alertButton = TPButton(color: .systemPink, title: "Ok")
    let containerView = UIView()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        addSubViews()
        constrainViews()
        customizeView()
        alertLabel.text = errorMessage
    }
    
    @objc func dismissVC() {
        self.dismiss(animated: true)
    }
    
    func addSubViews() {
        view.addSubview(containerView)
        containerView.addSubview(alertLabel)
        containerView.addSubview(alertButton)
    }
    
    func customizeView() {
        alertButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        alertLabel.textColor = .white
    }
    
    func constrainViews() {
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            containerView.heightAnchor.constraint(equalToConstant: 200),
            
            alertLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            alertLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            alertLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            alertLabel.heightAnchor.constraint(equalToConstant: 50),
            
            alertButton.topAnchor.constraint(equalTo: alertLabel.bottomAnchor, constant: 30),
            alertButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            alertButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            alertButton.heightAnchor.constraint(equalToConstant: 50)
        
        
        ])
        
    }

    

}
