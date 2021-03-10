//
//  ViewController.swift
//  TripPlanner
//
//  Created by Chris Withers on 3/8/21.
//

import UIKit
import Firebase

class ViewController: UIViewController {

    let createAcctButton = TPButton(color: .systemGreen, title: "Create Account")
    let loginButton = TPButton(color: .systemBlue, title: "Log In")
    
    let emailTextField = TPTextField(placeHolder: "Username")
    
    let passwordTextField = TPTextField(placeHolder: "Password")
    
    let db = Firestore.firestore()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .systemBackground
        addSubViews()
        constrainTextFields()
        constrainButtons()
        addButtonTargets()
    }
    
    func addButtonTargets() {
        loginButton.addTarget(self, action: #selector(goToDetail), for: .touchUpInside)
        createAcctButton.addTarget(self, action: #selector(goToDetail), for: .touchUpInside)
    }
    
    @objc func goToDetail(sender: UIButton) {

        if let email = emailTextField.text, let password = passwordTextField.text, !email.isEmpty, !password.isEmpty {
            switch sender {
            case loginButton:
                loginUser(email: email, password: password)
            case createAcctButton:
                createUser(email: email, password: password)
            default:
                print("Nothing")
            }
        } else {
            self.presentAlert(title: "Please fill out both fields")
        }
    }
    
    func createUser(email: String, password: String) {
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] (user, error) in
            
            guard let self = self else { return }
            
            if let error = error {
                //We have an error so show an alert
                self.presentAlert(title: error.localizedDescription)
            } else {
                //
                //Create a new user here with their User ID, then go to new view
                self.saveNewUser(email: email)
                let destination = DetailViewController()
                destination.email = "Logged in user: \(email)"
                destination.modalPresentationStyle = .overFullScreen
                destination.modalTransitionStyle = .crossDissolve
                self.present(destination, animated: true)
            }
            
            
        }
    }
    
    func saveNewUser(email: String) {
        guard let id = Auth.auth().currentUser?.uid else { return }
        // create new user in db with that id, and email and empty lists
        db.collection("users").document(id).setData([
            "email": email,
            "blocked": [],
            "friends": []
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    func loginUser(email: String, password: String) {
       
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (user, error) in
            guard let self = self else { return }
            
            if let error = error {
                //We have an error so show an alert
                self.presentAlert(title: error.localizedDescription)
            } else {
                //We logged in successfully
                let destination = DetailViewController()
                destination.email = "Logged in user: \(email)"
                destination.modalPresentationStyle = .overFullScreen
                destination.modalTransitionStyle = .crossDissolve
                self.present(destination, animated: true)
            }
            
            
            
        }
    }

    func addSubViews() {
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        view.addSubview(createAcctButton)
    }
    
    func constrainTextFields() {
        passwordTextField.isSecureTextEntry = true
        
        NSLayoutConstraint.activate([
            emailTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            emailTextField.heightAnchor.constraint(equalToConstant: 50),
            
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor),
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

