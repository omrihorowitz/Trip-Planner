//
//  MainMapViewController.swift
//  TripPlanner
//
//  Created by Chris Withers on 3/12/21.
//

import UIKit
import CoreLocation
import MapKit

class MainMapViewController: UIViewController, CLLocationManagerDelegate {

    //MARK: - Properties
    let locationManager = CLLocationManager()
        let regionInMeters: Double = 10000
        var previousLocation: CLLocation?
        var mapView = MKMapView()
        let goButton = UIButton()
        let planRouteButton = UIButton()
        let tripDetailLabel = UILabel()
        let searchBar = UISearchBar()
        let geoCoder = CLGeocoder()
        var directionsArray: [MKDirections] = []
        
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        goButtonSubview()
        //addSubViews()
        //allConfiguration()
        //checkLocationServices()
    }
    
    // MARK: - Actions
    @objc func goButtonTapped(sender : UIButton!){
        
    }

    @objc func planRouteButtonTapped(sender : UIButton!){
        let tripsDetailViewController = TripsListTableViewController()
                present(tripsDetailViewController, animated: true)
    }
    
    @objc func searchBar(sender : UISearchBar!){
        
    }
    
    func goButtonSubview() {
        goButton.backgroundColor = .green
        goButton.setTitle("Go", for: .normal)
        goButton.addTarget(self, action: #selector(goButtonTapped), for: .touchUpInside)
    }
    
}
