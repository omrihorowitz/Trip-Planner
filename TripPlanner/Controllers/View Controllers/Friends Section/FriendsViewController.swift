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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubviews(searchBar, segmentedControl)
        setConstraints()
        setUpSegmentedControl()
    }
    
    func setUpSegmentedControl() {
        segmentedControl.selectedSegmentIndex = 0
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

