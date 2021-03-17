//
//  TextDirectionsTableViewController.swift
//  TripPlanner
//
//  Created by Omri Horowitz on 3/16/21.
//

import UIKit
import MapKit
import CoreLocation


class TextDirectionsTableViewController: UITableViewController {

    var steps: [MKRoute.Step]?
    let cellId = "cellId"

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        guard let steps = steps else {return 0}
        return steps.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)

        guard let steps = self.steps else {return UITableViewCell()}
        let step = steps[indexPath.row]
        cell.textLabel?.text = step.instructions

        return cell
    }
}


// self.steps[0].distance (in meters)
// self.steps[0].instructions (instructions)
