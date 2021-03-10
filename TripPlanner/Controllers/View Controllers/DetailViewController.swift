//
//  DetailViewController.swift
//  TripPlanner
//
//  Created by Chris Withers on 3/9/21.
//

import UIKit
import Firebase

class DetailViewController: UIViewController {

    let logoutButton = TPButton(color: .systemRed, title: "Log Out")
    
    let usernameLabel = TPLabel(text: "Username of logged in user")
    
    let allFriendsLabel = TPLabel(text: "My friends")
    
    let peopleLabel = TPLabel(text: "All people")
    
    let myFriendsTableView = UITableView()
    
    let allPeopleTableView = UITableView()
    
    var email: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addSubViews()
        constrainViews()
        makeDelegates()
        registerCells()
        logoutButton.addTarget(self, action: #selector(logout), for: .touchUpInside)
        UserController.shared.fetchAllUsers { (result) in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    self.allPeopleTableView.reloadData()
                }
            case .failure(_):
                print("Error fetching people")
            }
        }
    }
    
    func registerCells() {
        allPeopleTableView.register(UITableViewCell.self, forCellReuseIdentifier: "DefaultCell")
        myFriendsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "DefaultCell")
    }
    
    func makeDelegates() {
        myFriendsTableView.delegate = self
        myFriendsTableView.dataSource = self
        allPeopleTableView.delegate = self
        allPeopleTableView.dataSource = self
    }
    
    @objc func logout() {
        do {
            try Auth.auth().signOut()
            dismiss(animated: true)
        } catch let signoutError as NSError {
            self.presentAlert(title: signoutError.localizedDescription)
        }
    }
    
    func addSubViews() {
        view.addSubview(usernameLabel)
        view.addSubview(logoutButton)
        view.addSubview(allPeopleTableView)
        view.addSubview(myFriendsTableView)
        view.addSubview(allFriendsLabel)
        view.addSubview(peopleLabel)
    }
    
    func constrainViews() {
        usernameLabel.text = email
        
        allPeopleTableView.translatesAutoresizingMaskIntoConstraints = false
        myFriendsTableView.translatesAutoresizingMaskIntoConstraints = false
        
        allPeopleTableView.backgroundColor = .systemBlue
        myFriendsTableView.backgroundColor = .systemGreen
        
        NSLayoutConstraint.activate([
            usernameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            usernameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            usernameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            
            allFriendsLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 50),
            allFriendsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            allFriendsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            
            
            myFriendsTableView.topAnchor.constraint(equalTo: allFriendsLabel.bottomAnchor, constant: 20),
            myFriendsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            myFriendsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            myFriendsTableView.heightAnchor.constraint(equalToConstant: 200),
            
            peopleLabel.topAnchor.constraint(equalTo: myFriendsTableView.bottomAnchor, constant: 20),
            peopleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            peopleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            
            
            allPeopleTableView.topAnchor.constraint(equalTo: peopleLabel.bottomAnchor, constant: 20),
            allPeopleTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            allPeopleTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            allPeopleTableView.heightAnchor.constraint(equalToConstant: 200),
            
            
            logoutButton.topAnchor.constraint(equalTo: allPeopleTableView.bottomAnchor, constant: 50),
            logoutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            logoutButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        
    }

}
extension DetailViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == allPeopleTableView {
            return UserController.shared.users.count
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)
        
        if tableView == allPeopleTableView {
            cell.backgroundColor = .systemBlue
            cell.textLabel?.text = UserController.shared.users[indexPath.row].email
        } else {
            cell.backgroundColor = .systemGreen
            cell.textLabel?.text = "Test Cell"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let destination = FriendViewController()
        self.present(destination, animated: true)
        
    }
    
    
}
