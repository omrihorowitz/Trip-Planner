//
//  AccountViewController.swift
//  TripPlanner
//
//  Created by Chris Withers on 3/12/21.
//

import UIKit
import Firebase

class AccountViewController: UIViewController {

    let logoutButton = TPButton(backgroundColor: .systemGray, title: "Logout")
    
    let deleteAccountButton = TPButton(backgroundColor: .systemRed, title: "Delete Account")
    
    let profileImageView = TPImageView(frame: .zero)
    
    let changePhotoButton = TPButton(backgroundColor: .systemGray, title: "Change photo")
    
    let nameTextField = TPTextField(placeHolder: "", isSecure: false)
    
    let saveNameButton = TPButton(backgroundColor: .systemGreen, title: "Save name")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubviews(logoutButton, deleteAccountButton, profileImageView, changePhotoButton, nameTextField, saveNameButton)
        constrainImageView()
        constrainChangePhotoButton()
        constrainNameTextField()
        constrainSaveNameButton()
        constrainLogout()
        constrainDeleteAccountButton()
        addButtonTargets()
        loadDataForView()
        view.backgroundColor = .systemBackground
        addCancelKeyboardGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    func loadDataForView() {
        
        guard let currentUser = UserController.shared.currentUser else { return }
        
        nameTextField.text = currentUser.name
        
        if currentUser.downloadURL != "No" {
            UserController.shared.fetchPhotoForUser(user: currentUser) { (result) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let image):
                        self.profileImageView.image = image
                    case .failure(_):
                        break
                    }
                }
            }
        }
        
    }
    
    func addButtonTargets() {
        logoutButton.addTarget(self, action: #selector(logout), for: .touchUpInside)
        deleteAccountButton.addTarget(self, action: #selector(deleteAccountButtonPressed), for: .touchUpInside)
        saveNameButton.addTarget(self, action: #selector(saveNameButtonTapped), for: .touchUpInside)
        changePhotoButton.addTarget(self, action: #selector(changePhotoButtonTapped), for: .touchUpInside)
    }
    
    @objc func changePhotoButtonTapped() {
        
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
        /*
         Request permission if we don't have it
         pull up picker view.
         Upon choosing a photo, first check if user already had a photo. If they did, delete it in cloud. Then upload new photo and get new dowloadURL and save it
         If they didn't have a photo, upload photo, get downloadURL and save it.
         */
        
        
        
    }
    
    @objc func saveNameButtonTapped() {
        
        guard let newName = nameTextField.text, !newName.isEmpty else {
            presentAlertOnMainThread(title: "Uh Oh", message: "Please enter a name", buttonTitle: "Ok")
            return
        }
        
        UserController.shared.currentUser?.name = newName
        
        UserController.shared.updateName(user: UserController.shared.currentUser) { (result) in
            switch result {
            case .success(_):
                self.presentAlertOnMainThread(title: "Success!", message: "Name updated!", buttonTitle: "Ok")
            case .failure(_):
                self.presentAlertOnMainThread(title: "Uh Oh!", message: "Can't update name at this time. Check internet and try again later.", buttonTitle: "Ok")
            }
        }
        
        
        
        
        
    }
    
    @objc func logout() {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signoutError as NSError {
            self.presentAlertOnMainThread(title: "Uh oh", message: signoutError.localizedDescription, buttonTitle: "Ok")
        }
    }
    
    @objc func deleteAccountButtonPressed() {
        
        
        let alert = UIAlertController(title: "Delete Account?", message: "Are you sure you want to delete your account? This cannot be undone.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            guard let currentUser = UserController.shared.currentUser else { return }
            UserController.shared.deleteAccount { [weak self] (result) in
                guard let self = self else { return }
                switch result {
                case .success(_):
                    self.logout()
                case .failure(_):
                    self.presentAlertOnMainThread(title: "Uh oh", message: "Could not delete account at this time", buttonTitle: "Ok")
                    self.logout()
                }
            }
        }))

        self.present(alert, animated: true)
        
    }
    
    func constrainImageView() {
        
        profileImageView.tintColor = .black
        
        NSLayoutConstraint.activate([
        
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),
            profileImageView.widthAnchor.constraint(equalTo: profileImageView.heightAnchor)
        ])
        
    }
    
    func constrainChangePhotoButton() {
        
        NSLayoutConstraint.activate([
            changePhotoButton.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 5),
            changePhotoButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 50),
            changePhotoButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -50)
        ])
        
    }
    
    func constrainNameTextField() {
        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: changePhotoButton.bottomAnchor, constant: 5),
            nameTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 50),
            nameTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -50)
        ])
    }
    
    func constrainSaveNameButton() {
        NSLayoutConstraint.activate([
            saveNameButton.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 5),
            saveNameButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 50),
            saveNameButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -50)
        ])
    }
    
    func constrainLogout() {
        NSLayoutConstraint.activate([
            logoutButton.topAnchor.constraint(equalTo: saveNameButton.bottomAnchor, constant: 5),
            logoutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            logoutButton.heightAnchor.constraint(equalToConstant: 75)
        ])
    }
    
    func constrainDeleteAccountButton() {
        NSLayoutConstraint.activate([
            deleteAccountButton.topAnchor.constraint(equalTo: logoutButton.bottomAnchor, constant: 20),
            deleteAccountButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            deleteAccountButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            deleteAccountButton.heightAnchor.constraint(equalToConstant: 75)
        ])
    }
    
}

extension AccountViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        
        //Check if they had an image already, and then replace it with this
        
        guard let imageData = image.pngData() else { return }
        
        profileImageView.image = image
        
        guard let currentUser = UserController.shared.currentUser else { return }
        
        let db = Firestore.firestore()
        
        let fireBaseForCurrentUser = db.collection("users").document(currentUser.id)
        
        if UserController.shared.currentUser?.downloadURL != "No" {
            //We have an old image
            UserController.shared.removePhotoInCloud { (result) in
                switch result {
                case .success(_):
                    UserController.shared.uploadPhotoForUser(imageData: imageData, email: currentUser.email) { (result) in
                        switch result {
                        case .success(let url):
                            fireBaseForCurrentUser.updateData(["downloadURL" : url])
                        case .failure(_):
                            self.presentAlertOnMainThread(title: "Uh oh", message: "Could not change photo at this time. Check internet and try again later.", buttonTitle: "Ok")
                        }
                    }
                case .failure(_):
                    self.presentAlertOnMainThread(title: "Uh oh", message: "Could not change photo at this time. Check internet and try again later.", buttonTitle: "Ok")
                }
            }
        } else {
            //We don't have an old photo
            UserController.shared.uploadPhotoForUser(imageData: imageData, email: currentUser.email) { (result) in
                switch result {
                case .success(let url):
                    fireBaseForCurrentUser.updateData(["downloadURL" : url])
                case .failure(_):
                    self.presentAlertOnMainThread(title: "Uh oh", message: "Could not change photo at this time. Check internet and try again later.", buttonTitle: "Ok")
                }
            }
        }
        
    }
    
    
}
