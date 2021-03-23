//
//  DirectionsTableViewController.swift
//  TripPlanner
//
//  Created by Chris Withers on 3/23/21.
//

import UIKit
import MapKit

class DirectionsTableViewController: UITableViewController {

    var steps: [MKRoute.Step] = []
    
    let cellID = "CellID"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return steps.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)

        cell.textLabel?.text = steps[indexPath.row].instructions

        return cell
    }
    
    

}
