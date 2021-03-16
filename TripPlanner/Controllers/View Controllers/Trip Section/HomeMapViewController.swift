//
//  HomeMapViewController.swift
//  TripPlanner
//
//  Created by Omri Horowitz on 3/16/21.
//
import MapKit
import UIKit

class HomeMapViewController: UIViewController {
    
    //MARK: - Outlets
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var etaLabel: UILabel!
    
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //MARK: - Actions

    
    @IBAction func planRouteButtonTapped(_ sender: Any) {
    }
    
    @IBAction func goButtonTapped(_ sender: Any) {
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
