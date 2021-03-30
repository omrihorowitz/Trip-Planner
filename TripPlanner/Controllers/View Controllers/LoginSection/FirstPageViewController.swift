//
//  FirstPageViewController.swift
//  TripPlanner
//
//  Created by Chris Withers on 3/12/21.
//

import UIKit

class FirstPageViewController: UIViewController {

    let logo = UIImageView(image: UIImage(named: "logo"))
    let loginButton = TPButton(backgroundColor: Colors.darkBlue!, title: "Login")
    let createAccountButton = TPButton(backgroundColor: Colors.darkBrown!, title: "Create Account")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.lightBrown
        navigationController?.navigationBar.isHidden = true
        view.addSubviews(loginButton, createAccountButton)
        constrainButtons()
        constrainLogo()
        addTargets()
        addCancelKeyboardGestureRecognizer()
    }
    
    func addTargets() {
        
        loginButton.addTarget(self, action: #selector(ActionButtonPressed(sender:)), for: .touchUpInside)
        createAccountButton.addTarget(self, action: #selector(ActionButtonPressed(sender:)), for: .touchUpInside)
    }
    
    func constrainButtons() {
        
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.titleLabel?.font = UIFont(name: "AmericanTypewriter-Bold", size: 25)
        createAccountButton.setTitleColor(.white, for: .normal)
        createAccountButton.titleLabel?.font = UIFont(name: "AmericanTypewriter-Bold", size: 25)
        
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
    
    func constrainLogo() {
        
//        logo.translatesAutoresizingMaskIntoConstraints = false
//        logo.contentMode = .scaleAspectFit
//            
//        NSLayoutConstraint.activate([
//            logo.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            logo.bottomAnchor.constraint(equalTo: loginButton.topAnchor, constant: -20),
//            logo.heightAnchor.constraint(equalToConstant: 50)
//        ])
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
