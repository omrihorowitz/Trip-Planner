//
//  ViewController.swift
//  TripPlanner
//
//  Created by Chris Withers on 3/8/21.
//

import UIKit

class ViewController: UIViewController {

    let createAcctButton = TPButton(color: .systemGreen, title: "Create Account")
    let loginButton = TPButton(color: .systemBlue, title: "Log In")
    
    let usernameTextField = TPTextField(placeHolder: "Username")
    
    let passwordTextField = TPTextField(placeHolder: "Password")
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .systemBackground
        addSubViews()
        constrainTextFields()
        constrainButtons()
        
        loginButton.addTarget(self, action: #selector(goToDetail), for: .touchUpInside)
        createAcctButton.addTarget(self, action: #selector(goToDetail), for: .touchUpInside)
    }
    
    @objc func goToDetail(sender: UIButton) {
        
        if sender == createAcctButton {
            let destination = TPAlertViewController()
            self.present(destination, animated: true)
        }
        
        
        let destination = DetailViewController()
        self.present(destination, animated: true)
        
//        if let username = usernameTextField.text, let password = passwordTextField.text {
//            switch sender {
//            case loginButton:
//                print("Login")
//            case createAcctButton:
//                print("Create account")
//            default:
//                print("none")
//            }
//        } else {
//            let destination = TPAlertViewController()
//            self.present(destination, animated: true)
//        }
        
        
    }

    func addSubViews() {
        view.addSubview(usernameTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        view.addSubview(createAcctButton)
    }
    
    func constrainTextFields() {
        passwordTextField.isSecureTextEntry = true
        
        NSLayoutConstraint.activate([
            usernameTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            usernameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            usernameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            usernameTextField.heightAnchor.constraint(equalToConstant: 50),
            
            passwordTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func constrainButtons() {
        NSLayoutConstraint.activate([
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 25),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            loginButton.heightAnchor.constraint(equalToConstant: 75),
            
            createAcctButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 10),
            createAcctButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            createAcctButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            createAcctButton.heightAnchor.constraint(equalToConstant: 75)
        ])
    }
    

}

