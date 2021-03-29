//
//  LoginViewController.swift
//  TripPlanner
//
//  Created by Chris Withers on 3/12/21.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    let emailTextField = TPTextField(placeHolder: "Email", isSecure: false)
    let passwordTextField = TPTextField(placeHolder: "Password", isSecure: true)
    let loginButton = TPButton(backgroundColor: .systemGreen, title: "Go!")

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = false
        view.backgroundColor = .systemBackground
        view.addSubviews(emailTextField, passwordTextField, loginButton)
        constrainViews()
        setButtonTarget()
        emailTextField.text = "c@c.com"
        passwordTextField.text = "123456"
        addCancelKeyboardGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillAppear(animated)
    }
    
    func setButtonTarget() {
        loginButton.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
    }
    
    @objc func actionButtonPressed() {
        guard let email = emailTextField.text, let password = passwordTextField.text, !email.isEmpty, !password.isEmpty else {
            self.presentAlertOnMainThread(title: "Uh oh!", message: "Please fill out both fields", buttonTitle: "Ok")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (result, error) in
            guard let self = self else { return }
            if let error = error {
                self.presentAlertOnMainThread(title: "Uh oh", message: error.localizedDescription, buttonTitle: "ok")
            } else {
                let tabBar = TabBarViewController()
                self.navigationController?.pushViewController(tabBar, animated: true)
            }
        }
    }
    
    func constrainViews() {
        
        NSLayoutConstraint.activate([
        
            emailTextField.bottomAnchor.constraint(equalTo: passwordTextField.topAnchor, constant: -20),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            emailTextField.heightAnchor.constraint(equalToConstant: 50),
            
            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            passwordTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            loginButton.heightAnchor.constraint(equalToConstant: 50)
        
        
        ])
        
        
    }

    

}
