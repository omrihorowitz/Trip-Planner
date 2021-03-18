//
//  TripsViewController.swift
//  TripPlanner
//
//  Created by Chris Withers on 3/12/21.
//

import UIKit

class TripsViewController: UIViewController {
    
    let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        self.navigationItem.title = "Trips"
        setupTableView()
        setUpHeaderView()
        addCancelKeyboardGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    
    func setUpHeaderView() {
        let headerView = UIView(frame: CGRect(x: 0,
                                              y: 0,
                                              width: self.tableView.frame.width,
                                              height: 50))
        let removeAllButton: UIButton = {
            let removeAllButton = UIButton()
            removeAllButton.setTitle("Add Trip", for: .normal)
            removeAllButton.setTitleColor(.systemGreen, for: .normal)
            return removeAllButton
        }()
        
        removeAllButton.addTarget(self, action: #selector(addTripButtonTapped), for: .touchUpInside)
        
        headerView.addSubview(removeAllButton)
        removeAllButton.translatesAutoresizingMaskIntoConstraints = false
        removeAllButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        removeAllButton.centerXAnchor.constraint(equalTo: headerView.centerXAnchor).isActive = true
        
        
        headerView.backgroundColor = .white
        
        tableView.tableHeaderView = headerView
    }
    
    
    func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.rowHeight = 40
        tableView.delegate = self
        tableView.dataSource = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    
    @objc func addTripButtonTapped() {
        let newViewController = TripDetailViewController()
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
    
}


extension TripsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        
        // Configure the cell...
        
        return UITableViewCell()
    }
    
    
}


