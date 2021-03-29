//
//  TripsViewController.swift
//  TripPlanner
//
//  Created by Chris Withers on 3/12/21.
//

import UIKit

class TripsViewController: UIViewController {
    
    let tableView = UITableView()
    let cellID = "CellID"
    
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
        fetchTrips()
    }
    
    func fetchTrips() {
        TripController.shared.fetchAllTrips { [weak self] (result) in
            
            guard let self = self else { return }
            
            switch result {
            case .success(_):
                self.tableView.reloadData()
            case .failure(_):
                self.presentAlertOnMainThread(title: "Uh oh", message: "Can't seem to find your trips! Try again later", buttonTitle: "Ok")
            }
        }
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
        tableView.register(TripTableViewCell.self, forCellReuseIdentifier: TripTableViewCell.cellID)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
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
        return TripController.shared.allTrips.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       guard let cell = tableView.dequeueReusableCell(withIdentifier: TripTableViewCell.cellID) as? TripTableViewCell else { return UITableViewCell ()}
        
        let currentTrip = TripController.shared.allTrips[indexPath.row]
        
        cell.configure(trip: currentTrip)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let destination = TripDetailViewController()
        let tripSelected = TripController.shared.allTrips[indexPath.row]
        destination.trip = tripSelected
        navigationController?.pushViewController(destination, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let tripToDelete = TripController.shared.allTrips[indexPath.row]
            TripController.shared.deleteTrip(trip: tripToDelete) { [weak self] (result) in
                guard let self = self else { return }
                switch result {
                case .success(_):
                    DispatchQueue.main.async {
                        TripController.shared.allTrips.remove(at: indexPath.row)
                        tableView.reloadData()
                    }
                case .failure(_):
                    self.presentAlertOnMainThread(title: "Uh oh", message: "Could not remove trip at this time. Check internet and try again later.", buttonTitle: "Ok")
                }
            }
        }
    }
    
    
}


