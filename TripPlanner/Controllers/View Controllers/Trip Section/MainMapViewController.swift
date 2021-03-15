//
//  MainMapViewController.swift
//  TripPlanner
//
//  Created by Chris Withers on 3/12/21.
//

import UIKit
import CoreLocation
import MapKit

class MainMapViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate {
    
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
        addAllSubviews()
        addAllConfiguration()
        checkLocationServices()
        addCancelKeyboardGestureRecognizer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
      }
    
    // MARK: - Actions
    @objc func goButtonTapped(sender : UIButton!){
        //        resetMapView(withNew: MKDirections) //tbd
        //mapping the route from user to the selected pin
    }
    
    @objc func planRouteButtonTapped(sender : UIButton!){
        //        resetMapView(withNew: MKDirections) //tbd
        let tripDetailViewController = TripDetailViewController()
        present(tripDetailViewController, animated: true)
    }
    
    @objc func searchBar(sender : UISearchBar!){
        //hide keyboard if tap away
        //show suggestions
        //press suggestions for autocomplete
    }
    
    //MARK: - Methods
    
    func addAllSubviews() {
        view.addSubview(mapView)
        view.addSubview(planRouteButton)
        view.addSubview(goButton)
        view.addSubview(tripDetailLabel)
        view.addSubview(searchBar)
    }
    
    
    func addAllConfiguration() {
        //add all configurations
        configureMapView()
        configurePlanRouteButton()
        configureTripDetailLabel()
        configureSearchBar()
        configureGoButton()
    }
    
    func configureMapView() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        mapView.mapType = MKMapType.mutedStandard //diff map types
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.delegate = self
        //        mapView.register(
        //            LandmarkView.self,
        //            forAnnotationViewWithReuseIdentifier:
        //                MKMapViewDefaultAnnotationViewReuseIdentifier)  // would need unique identifier w more classes
        //        mapView.addAnnotations(whatever pins we annnotate)
    }
    
    func configurePlanRouteButton() {
        planRouteButton.translatesAutoresizingMaskIntoConstraints = false
        planRouteButton.backgroundColor = .systemGreen
        planRouteButton.setTitleColor(UIColor.white, for: .normal)
        planRouteButton.setTitle("Plan Route", for: .normal)
        planRouteButton.addTarget(self, action: #selector(planRouteButtonTapped), for: .touchUpInside)
        NSLayoutConstraint.activate([
            planRouteButton.heightAnchor.constraint(equalToConstant: 30),
            planRouteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            //planRouteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -150),
            planRouteButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30)
        ])
        planRouteButton.layer.cornerRadius = 10
        planRouteButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        planRouteButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        planRouteButton.clipsToBounds = true
    }
    
    func configureGoButton() {
        goButton.translatesAutoresizingMaskIntoConstraints = false
        goButton.backgroundColor = .systemGreen
        goButton.setTitleColor(UIColor.white, for: .normal)
        goButton.setTitle("Go", for: .normal)
        goButton.addTarget(self, action: #selector(goButtonTapped), for: .touchUpInside)
        NSLayoutConstraint.activate([
            goButton.heightAnchor.constraint(equalToConstant: 30),
            //goButton.leadingAnchor.constraint(equalTo: view.trailingAnchor, constant: -150),
            goButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            goButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30)
        ])
        goButton.layer.cornerRadius = 10
        goButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        goButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        goButton.clipsToBounds = true
    }
    
    func configureTripDetailLabel() {
        tripDetailLabel.translatesAutoresizingMaskIntoConstraints = false
        tripDetailLabel.backgroundColor = .white
        tripDetailLabel.textColor = .black
        tripDetailLabel.text = "ETA 525,600 min / 1k miles"
        NSLayoutConstraint.activate([
            tripDetailLabel.heightAnchor.constraint(equalToConstant: 30),
            tripDetailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tripDetailLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tripDetailLabel.bottomAnchor.constraint(equalTo: goButton.topAnchor, constant: -10)
        ])
        tripDetailLabel.layer.cornerRadius = 10
        tripDetailLabel.layer.masksToBounds = true
        tripDetailLabel.textAlignment = .center
        tripDetailLabel.widthAnchor.constraint(equalToConstant: 175).isActive = true
        tripDetailLabel.heightAnchor.constraint(equalToConstant: 35).isActive = true
    }
    
    func configureSearchBar() {
        let searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
           print("Error fetching location")
        }
    }
    
    func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            startTrackingUserLocation()
        case .denied:
            locationManager.requestWhenInUseAuthorization()
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            locationManager.requestWhenInUseAuthorization()
            break
        case .authorizedAlways:
            startTrackingUserLocation()
        @unknown default:
            break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    func startTrackingUserLocation() {
        mapView.showsUserLocation = true
        centerViewOnUserLocation()
        locationManager.startUpdatingLocation()
        previousLocation = getCenterLocation(for: mapView)
    }
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitutde = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitutde)
    }
    
    //    func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request {
    //        let destinationCoordinate       = getCenterLocation(for: mapView).coordinate //this is where the pin is
    //        let startingLocation            = MKPlacemark(coordinate: coordinate) //user location
    //        let destination                 = MKPlacemark(coordinate: destinationCoordinate) // coordinate from destinationcoordinate
    //
    //        let request                     = MKDirections.Request() // this is how you request directions
    //        request.source                  = MKMapItem(placemark: startingLocation)
    //        request.destination             = MKMapItem(placemark: destination)
    //        request.transportType           = .automobile
    //        request.requestsAlternateRoutes = false //switch later for alternate routes
    //
    // getting start and stop from detail view // plus additional stops
    
    //        return request
    //    }
    //
    //    func resetMapView(withNew directions: MKDirections) {
    //        mapView.removeOverlays(mapView.overlays)
    //        directionsArray.append(directions)
    //        let _ = directionsArray.map { $0.cancel() }
    //        directionsArray.removeLast() //not sure about this one
    //    }
    
    //label delegate --- getting its info from the detail view
    
    func resetMapView(withNew directions: MKDirections) {
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map { $0.cancel() }
        directionsArray.removeLast() //not sure about this one
    }
}

//MARK: - Extensions

private extension MKMapView {
    func centerToLocation(
        _ location: CLLocation,
        regionRadius: CLLocationDistance = 1000
    ) {
        let coordinateRegion = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: regionRadius, //default 1k meters
            longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
}

extension MainMapViewController: MKMapViewDelegate {
    //    func mapView(
    //        _ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    
    // decide what annotations we're throwin in models. just set photo and type that would show up in search
    //
    //        guard let landmark = view.annotation as? Landmark else {
    //            return
    //        }
    //
    //        let launchOptions = [
    //            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
    //        ]
    //        landmark.mapItem?.openInMaps(launchOptions: launchOptions)
    //    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue //color of the polyline
        
        return renderer
    }
    //will need a pic resizing function
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        switch annotation {
        // 1
        case let user as MKUserLocation:
            // 2
            if let existingView = mapView
                .dequeueReusableAnnotationView(withIdentifier: "profilepic") //changed out for code relating to user profile pic in firebase
            {
                return existingView
            } else {
                // 3
                let view = MKAnnotationView(annotation: user, reuseIdentifier: "profilepic") //changed out for code relating to user profile pic in firebase
                view.image = #imageLiteral(resourceName: "profilepic")
                view.layer.cornerRadius = view.frame.size.height/2
                view.layer.masksToBounds = true
                
                return view
            }
        default:
            return nil
        }
    }
}

extension UIViewController {
    func addCancelKeyboardGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}//End of extension
