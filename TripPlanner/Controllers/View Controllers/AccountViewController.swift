//
//  AccountViewController.swift
//  TripPlanner
//
//  Created by Chris Withers on 3/12/21.
//

import UIKit
import Firebase
import Photos

class AccountViewController: UIViewController {
    
    let scrollView = UIScrollView()
    
    let contentView = UIView()
    
    let rateButton = TPButton(backgroundColor: .systemGreen, title: "Rate App!")

    let logoutButton = TPButton(backgroundColor: Colors.darkBlue ?? UIColor(), title: "Logout")
    
    let deleteAccountButton = TPButton(backgroundColor: .systemRed, title: "Delete Account")
    
    let profileImageView = TPImageView(frame: .zero)
    
    let changePhotoButton = TPButton(backgroundColor: .systemGray, title: "Change photo")
    
    let nameTextField = TPTextField(placeHolder: "Edit name...", isSecure: false)
    
    let saveNameButton = TPButton(backgroundColor: .systemGreen, title: "Save name")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        constrainScrollView()
        constrainImageView()
        constrainChangePhotoButton()
        constrainNameTextField()
        constrainSaveNameButton()
        constrainLogout()
        constrainDeleteAccountButton()
        constrainRateButton()
        addButtonTargets()
        loadDataForView()
        view.backgroundColor = Colors.lightBrown
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
        rateButton.addTarget(self, action: #selector(rateButtonTapped), for: .touchUpInside)
    }
    
    @objc func changePhotoButtonTapped() {
        
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
        //handle authorized status
            DispatchQueue.main.async {
                let picker = UIImagePickerController()
                picker.sourceType = .photoLibrary
                picker.allowsEditing = true
                picker.delegate = self
                self.present(picker, animated: true)
            }
        case .denied, .restricted :
        presentAlertOnMainThread(title: "Uh oh", message: "Please allow access to photos to change your profile pic", buttonTitle: "Ok")
        case .notDetermined:
            // ask for permissions
            PHPhotoLibrary.requestAuthorization { status in
                switch status {
                case .authorized:
                // as above
                    DispatchQueue.main.async {
                        let picker = UIImagePickerController()
                        picker.sourceType = .photoLibrary
                        picker.allowsEditing = true
                        picker.delegate = self
                        self.present(picker, animated: true)
                    }
                case .denied, .restricted:
                // as above
                    self.presentAlertOnMainThread(title: "Uh oh", message: "Please allow access to photos to change your profile pic", buttonTitle: "Ok")
                case .notDetermined:
                // won't happen but still
                    self.presentAlertOnMainThread(title: "Uh oh", message: "Please allow access to photos to change your profile pic", buttonTitle: "Ok")
                @unknown default:
                    break
                }
            }
        @unknown default:
            print("Unknown")
        }
        
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
    
    @objc func rateButtonTapped() {
        guard let writeReviewURL = URL(string: "https://apps.apple.com/app/id1560717810?action=write-review")
        else { fatalError("Expected a valid URL") }
        UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
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
    
    func constrainScrollView(){
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        scrollView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
    }
    
    func constrainImageView() {
        
        profileImageView.tintColor = .black
        scrollView.addSubview(profileImageView)
        
        NSLayoutConstraint.activate([
        
            profileImageView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.heightAnchor.constraint(equalToConstant: 200),
            profileImageView.widthAnchor.constraint(equalTo: profileImageView.heightAnchor)
        ])
        
    }
    
    func constrainChangePhotoButton() {
        
        scrollView.addSubview(changePhotoButton)
        changePhotoButton.backgroundColor = Colors.darkBrown
        changePhotoButton.titleLabel?.font = UIFont(name: "AmericanTypewriter-Bold", size: 15)
        
        NSLayoutConstraint.activate([
            changePhotoButton.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10),
            changePhotoButton.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 70),
            changePhotoButton.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -70),
            changePhotoButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
    }
    
    func constrainNameTextField() {
        
        scrollView.addSubview(nameTextField)
        nameTextField.backgroundColor = Colors.lightBrown
        let attributes = [
//            NSForegroundColorAttributeName: UIColor.blackColor(),
            NSAttributedString.Key.font : UIFont(name: "AmericanTypewriter-Bold", size: 15)! // Note the !
        ]

        nameTextField.attributedPlaceholder = NSAttributedString(string: "Name here...", attributes:attributes)
        nameTextField.font = UIFont(name: "AmericanTypewriter-Bold", size: 18)
        nameTextField.textColor = Colors.darkBlue
        
        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: changePhotoButton.bottomAnchor, constant: 40),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 50),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -50),
            nameTextField.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func constrainSaveNameButton() {
        
        scrollView.addSubview(saveNameButton)
        saveNameButton.backgroundColor = Colors.darkBrown
        saveNameButton.titleLabel?.font = UIFont(name: "AmericanTypewriter-Bold", size: 15)
        
        NSLayoutConstraint.activate([
            saveNameButton.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 15),
            saveNameButton.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 50),
            saveNameButton.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -50),
            saveNameButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func constrainLogout() {
        
        scrollView.addSubview(logoutButton)
        logoutButton.titleLabel?.font = UIFont(name: "AmericanTypewriter-Bold", size: 20)
        
        NSLayoutConstraint.activate([
            logoutButton.topAnchor.constraint(equalTo: saveNameButton.bottomAnchor, constant: 40),
            logoutButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 50),
            logoutButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -50),
            logoutButton.heightAnchor.constraint(equalToConstant: 75)
        ])
    }
    
    func constrainDeleteAccountButton() {
        
        scrollView.addSubview(deleteAccountButton)
        deleteAccountButton.titleLabel?.font = UIFont(name: "AmericanTypewriter-Bold", size: 20)
        
        NSLayoutConstraint.activate([
            deleteAccountButton.topAnchor.constraint(equalTo: logoutButton.bottomAnchor, constant: 15),
            deleteAccountButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 50),
            deleteAccountButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -50),
            deleteAccountButton.heightAnchor.constraint(equalToConstant: 75)
        ])
    }
    
    func constrainRateButton(){
        scrollView.addSubview(rateButton)
        rateButton.titleLabel?.font = UIFont(name: "AmericanTypewriter-Bold", size: 15)
        
        NSLayoutConstraint.activate([
            rateButton.topAnchor.constraint(equalTo: deleteAccountButton.bottomAnchor, constant: 40),
            rateButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 70),
            rateButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -70),
            rateButton.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            rateButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
}

extension AccountViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        
        //Check if they had an image already, and then replace it with this
        
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        
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
