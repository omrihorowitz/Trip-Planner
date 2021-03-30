//
//  FriendsViewController.swift
//  TripPlanner
//
//  Created by Chris Withers on 3/12/21.
//

import UIKit
import Firebase

class FriendsViewController: UIViewController {

    let searchBar = UISearchBar()
    
    let segmentedControl = UISegmentedControl(items: ["Friends", "Sent", "Received", "Add"])
    
    var collectionView: UICollectionView!
    
    var isSearching: Bool = false
    
    enum Section {
        case main
    }
    
    var dataSource: UICollectionViewDiffableDataSource<Section, User>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubviews(searchBar, segmentedControl)
        setConstraints()
        setUpSegmentedControl()
        setUpCollectionView()
        fetchUsers()
        setUpDataSource()
        searchBar.delegate = self
        UserController.shared.delegate = self
        searchBar.autocapitalizationType = .none
        addCancelKeyboardGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillLayoutSubviews() {
        setUpColors()
    }
    
    func setUpColors() {
        view.backgroundColor = Colors.brown
        searchBar.barTintColor = Colors.lightBrown
        searchBar.backgroundColor = Colors.brown
        searchBar.searchTextField.textColor = Colors.darkBlue
        searchBar.searchTextField.font = UIFont(name: "AmericanTypewriter-Bold", size: 15)
        searchBar.autocapitalizationType = .words
        segmentedControl.selectedSegmentTintColor = Colors.darkBrown
        segmentedControl.backgroundColor = Colors.brown
        collectionView.backgroundColor = Colors.brown
//        let font = [NSAttributedString.Key.font : UIFont(name: "AmericanTypewriter-Bold", size: 15)]
        let titleTextAttributesForSelected = [NSAttributedString.Key.foregroundColor: Colors.lightBlue]
        let titleTextAttributesForNormal = [NSAttributedString.Key.foregroundColor: Colors.darkBlue]
        segmentedControl.setTitleTextAttributes(titleTextAttributesForSelected as [NSAttributedString.Key : Any], for: .selected)
        segmentedControl.setTitleTextAttributes(titleTextAttributesForNormal as [NSAttributedString.Key : Any], for: .normal)
//        segmentedControl.setTitleTextAttributes(font as [NSAttributedString.Key : Any], for: .normal)
//        segmentedControl.setTitleTextAttributes(font as [NSAttributedString.Key : Any], for: .selected)
    }
    
    func setUpCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: UIHelper.createThreeColumnFlowLayout(in: self.view))
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
        collectionView.register(TPPersonCollectionViewCell.self, forCellWithReuseIdentifier: TPPersonCollectionViewCell.reuseID)
    }
    
    func setUpDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, User>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, user) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TPPersonCollectionViewCell.reuseID, for: indexPath) as! TPPersonCollectionViewCell
            cell.set(user: user)
            return cell
        })
    }
    
    func updateData(listOfUsers: [User]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, User>()
        snapshot.appendSections([.main])
        snapshot.appendItems(listOfUsers)
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
    
    func fetchUsers() {
        
        UserController.shared.fetchAllUsers { (result) in
            switch result {
            case .success(_):
            break
            case .failure(_):
                print("Nay")
            }
        }
    }
    
    func setUpSegmentedControl() {
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentControlChanged(sender:)), for: .valueChanged)
    }
    
    @objc func segmentControlChanged(sender: UISegmentedControl) {
        
        isSearching = false
        switch sender.selectedSegmentIndex {
        case 0:
            UserController.shared.fetchFriends()
            updateData(listOfUsers: UserController.shared.friends)
        case 1:
            UserController.shared.fetchSent()
            updateData(listOfUsers: UserController.shared.sent)
        case 2:
            UserController.shared.fetchReceived()
            updateData(listOfUsers: UserController.shared.received)
        case 3:
            UserController.shared.fetchAddable()
            updateData(listOfUsers: [])
        default:
            break
        }
    }
    
    func setConstraints() {
        
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            
            segmentedControl.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 5),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        
        ])
    }
    
}

extension FriendsViewController : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var userToSelect: User?
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            if isSearching {
                userToSelect = UserController.shared.filtered[indexPath.row]
            } else {
                userToSelect = UserController.shared.friends[indexPath.row]
            }
        case 1:
            if isSearching {
                userToSelect = UserController.shared.filtered[indexPath.row]
            } else {
                userToSelect = UserController.shared.sent[indexPath.row]
            }
        case 2:
            if isSearching {
                userToSelect = UserController.shared.filtered[indexPath.row]
            } else {
                userToSelect = UserController.shared.received[indexPath.row]
            }
        case 3:
            userToSelect = UserController.shared.filtered[indexPath.row]
        default:
            break
        }
        
        let destination = PersonDetailViewController()
        destination.user = userToSelect
        destination.delegate = self
        navigationController?.pushViewController(destination, animated: true)
    }
    
}

extension FriendsViewController : UISearchBarDelegate {
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        isSearching = false
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            updateData(listOfUsers: UserController.shared.friends)
        case 1:
            updateData(listOfUsers: UserController.shared.sent)
        case 2:
            updateData(listOfUsers: UserController.shared.received)
        case 3:
            updateData(listOfUsers: UserController.shared.filtered)
        default:
            break
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            
            guard searchText.count > 0 else {
                updateData(listOfUsers: UserController.shared.friends)
                isSearching = false
                return }
            
            isSearching = true
            UserController.shared.filterList(list: UserController.shared.friends, searchTerm: searchText)
        case 1:
            
            guard searchText.count > 0 else {
                updateData(listOfUsers: UserController.shared.sent)
                isSearching = false
                return }
            
            isSearching = true
            UserController.shared.filterList(list: UserController.shared.sent, searchTerm: searchText)
        case 2:
            
            guard searchText.count > 0 else {
                updateData(listOfUsers: UserController.shared.received)
                isSearching = false
                return }
            
            isSearching = true
            UserController.shared.filterList(list: UserController.shared.received, searchTerm: searchText)
        case 3:
            
            guard searchText.count > 0 else {
                updateData(listOfUsers: [])
                isSearching = false
                return }
            
            isSearching = true
            UserController.shared.filterList(list: UserController.shared.addable, searchTerm: searchText)
        default:
            break
        }
        updateData(listOfUsers: UserController.shared.filtered)
    }
    
}

extension FriendsViewController : PersonDetailButtonProtocol {
    func buttonSelected(title: String, message: String) {
        updateCollectionView()
        self.presentAlertOnMainThread(title: title, message: message, buttonTitle: "Ok")
    }
}

extension FriendsViewController : FireBaseUpdatedDelegate {
    func updateCollectionView() {
        print("Called!")
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            UserController.shared.fetchFriends()
            updateData(listOfUsers: UserController.shared.friends)
        case 1:
            UserController.shared.fetchSent()
            updateData(listOfUsers: UserController.shared.sent)
        case 2:
            UserController.shared.fetchReceived()
            updateData(listOfUsers: UserController.shared.received)
        case 3:
            UserController.shared.fetchAddable()
            updateData(listOfUsers: [])
        default:
            break
        }
    }
    
}
