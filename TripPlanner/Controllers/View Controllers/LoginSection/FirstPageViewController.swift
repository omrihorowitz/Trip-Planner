//
//  FirstPageViewController.swift
//  TripPlanner
//
//  Created by Chris Withers on 3/12/21.
//

import UIKit

class FirstPageViewController: UIViewController {

    let loginButton = TPButton(backgroundColor: .systemGreen, title: "Login")
    let createAccountButton = TPButton(backgroundColor: .systemTeal, title: "Create Account")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.isHidden = true
        view.addSubviews(loginButton, createAccountButton)
        constrainButtons()
        addTargets()
        addCancelKeyboardGestureRecognizer()
    }
    
    func addTargets() {
        
        loginButton.addTarget(self, action: #selector(ActionButtonPressed(sender:)), for: .touchUpInside)
        createAccountButton.addTarget(self, action: #selector(ActionButtonPressed(sender:)), for: .touchUpInside)
    }
    
    func constrainButtons() {
        
        NSLayoutConstraint.activate([
            loginButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            loginButton.heightAnchor.constraint(equalToConstant: 75),
        
            createAccountButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20),
            createAccountButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            createAccountButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            createAccountButton.heightAnchor.constraint(equalToConstant: 75)
        
        
        ])
    }
    
    @objc func ActionButtonPressed(sender: UIButton) {
        switch sender {
        case loginButton:
            let loginVC = LoginViewController()
            navigationController?.pushViewController(loginVC, animated: true)
        case createAccountButton:
            let createAccountVC = CreateAccountViewController()
            navigationController?.pushViewController(createAccountVC, animated: true)
        default:
            break
        }
    }
    

}
