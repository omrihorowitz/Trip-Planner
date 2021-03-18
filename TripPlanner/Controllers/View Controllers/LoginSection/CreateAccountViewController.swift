//
//  CreateAccountViewController.swift
//  TripPlanner
//
//  Created by Chris Withers on 3/12/21.
//

import UIKit
import Firebase


class CreateAccountViewController: UIViewController {

    let imageView = UIImageView()
    let changeImageButton = TPButton(backgroundColor: .systemGray, title: " Change Image ")
    let nameTextField = TPTextField(placeHolder: "Name", isSecure: false)
    let emailTextField = TPTextField(placeHolder: "Email", isSecure: false)
    let passwordTextField = TPTextField(placeHolder: "Password", isSecure: true)
    let confirmPasswordTextField = TPTextField(placeHolder: "Confirm Password", isSecure: true)
    let createAccountButton = TPButton(backgroundColor: .systemTeal, title: "Let's Go!")
    
    var imageData: Data?
    
    let db = Firestore.firestore()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = false
        view.backgroundColor = .systemBackground
        view.addSubviews(nameTextField, emailTextField, passwordTextField, confirmPasswordTextField, createAccountButton, imageView, changeImageButton)
        constrainViews()
        setUpButtonTargets()
        addCancelKeyboardGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillAppear(animated)
    }
    
    func setUpButtonTargets() {
        createAccountButton.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        changeImageButton.addTarget(self, action: #selector(changePhotoButtonTapped), for: .touchUpInside)
    }
    
    @objc func changePhotoButtonTapped() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc func actionButtonPressed() {
        
        //Check all fields are filled out
        guard let name = nameTextField.text, let email = emailTextField.text, let password = passwordTextField.text, let confirmed = confirmPasswordTextField.text, !name.isEmpty, !email.isEmpty, !password.isEmpty, !confirmed.isEmpty else { self.presentAlertOnMainThread(title: "Uh oh!", message: "Please fill out all fields to create account", buttonTitle: "Ok"); return}
        
        //check passwords match
        guard password == confirmed else {
            self.presentAlertOnMainThread(title: "Uh oh!", message: "Please make sure passwords match", buttonTitle: "Ok")
            return }
        
        //try to create account
        if let imageData = self.imageData {
            //User picked an image so save the image and then make a user with the image URL
            UserController.shared.uploadPhotoForUser(imageData: imageData, email: email) { [weak self] (result) in
                
                guard let self = self else { return }
                
                switch result{
                case .success(let url):
                    self.createUser(email: email, password: password, name: name, downloadURL: url)
                case .failure(_):
                    self.presentAlertOnMainThread(title: "Uh oh", message: "Couldn't upload photo at this time", buttonTitle: "Ok")
                }
            }
        } else{
            // User didn't pick an image so save just save user. Download URL will just be "no"
            self.createUser(email: email, password: password, name: name, downloadURL: nil)
        }
        
    }
    
    
    func createUser(email: String, password: String, name: String, downloadURL: String?) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] (result, error) in
            guard let self = self else { return }
            if let error = error {
                self.presentAlertOnMainThread(title: "Error", message: error.localizedDescription, buttonTitle: "Ok")
            } else {
                UserController.shared.createUserInDB(email: email.lowercased(), name: name, downloadURL: downloadURL)
                let tabBar = TabBarViewController()
                self.navigationController?.pushViewController(tabBar, animated: true)
            }
        }
    }
    
    func constrainViews() {
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.tintColor = .black
        
        NSLayoutConstraint.activate([
            
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 100),
            imageView.widthAnchor.constraint(equalToConstant: 100),
            
            changeImageButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 5),
            changeImageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            changeImageButton.heightAnchor.constraint(equalToConstant: 30),
            
            emailTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            emailTextField.heightAnchor.constraint(equalToConstant: 50),
            
            
            
            nameTextField.bottomAnchor.constraint(equalTo: emailTextField.topAnchor, constant: -20),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            nameTextField.heightAnchor.constraint(equalToConstant: 50),
            
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            confirmPasswordTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            confirmPasswordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            createAccountButton.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: 20),
            createAccountButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            createAccountButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            createAccountButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}

extension CreateAccountViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        
        guard let imageData = image.pngData() else { return }
        self.imageData = imageData
        imageView.image = image
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
}
