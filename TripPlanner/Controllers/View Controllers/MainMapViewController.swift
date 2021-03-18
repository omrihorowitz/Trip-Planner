//
//  ViewController.swift
//  TripPlanner
//
//  Created by Chris Withers on 3/8/21.
//
import CoreLocation
import UIKit
import MapKit

class MainMapViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate {
    
    //MARK: - Properties
    
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 10000
    var previousLocation: CLLocation?
    var userLocation: CLLocationCoordinate2D? = nil
    var mapView = MKMapView()
    let etaLabel = UILabel()
    let goButton = UIButton()
    let planRouteButton = UIButton()
    let textDirectionsButton = UIButton()
    let geoCoder = CLGeocoder()
    var directionsArray: [MKDirections] = []
    var resultSearchController: UISearchController? = nil
    var selectedPin : MKPlacemark? = nil
    var pinLocation: CLLocationCoordinate2D? = nil
    var currentPlace: CLPlacemark?
    var etaMiles: CLLocationDistance?
    var etaTime: Double?
    var steps = [MKRoute.Step]()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addSubViews()
        allConfiguration()
        checkLocationServices()
        addCancelKeyboardGestureRecognizer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //MARK: - Actions
    
    @objc func planRouteButtonTapped(sender : UIButton!) {
        let routeSelectionViewController = RouteSelectionViewController()
        present(routeSelectionViewController, animated: true)
    }
    
    @objc func goButtonTapped(sender : UIButton!) {
        self.mapView.overlays.forEach {
                if ($0 is MKPolyline) {
                    self.mapView.removeOverlay($0)
                }
            }
        pinLocation = selectedPin?.coordinate
        userLocation = locationManager.location!.coordinate
        showRouteOnMap(startCoordinate: userLocation!, endCoordinate: pinLocation!) //fix the force unwrapping
    }
    
    @objc func textDirectionsButtonTapped(sender : UIButton!) {
        let destination = TextDirectionsTableViewController()
        destination.steps = self.steps
        destination.modalPresentationStyle = .pageSheet
        present(destination, animated: true)
    }
    
    //MARK: - Methods
    
    func allConfiguration() {
        configureMap()
        configureETALabel()
        configurePlanRouteButton()
        configureGoButton()
        configureSearchBar()
        configureTextDirectionsButton()
    }
    
    func addSubViews() {
        view.addSubview(mapView)
        view.addSubview(etaLabel)
        view.addSubview(planRouteButton)
        view.addSubview(goButton)
        view.addSubview(textDirectionsButton)
    }
    
    func configureMap() {
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
    }
    
    func configurePlanRouteButton() {
        planRouteButton.translatesAutoresizingMaskIntoConstraints = false
        planRouteButton.backgroundColor = .systemGreen
        planRouteButton.setTitleColor(UIColor.white, for: .normal)
        planRouteButton.setTitle("Plan", for: .normal)
        planRouteButton.addTarget(self, action: #selector(planRouteButtonTapped), for: .touchUpInside)
        NSLayoutConstraint.activate([
            planRouteButton.heightAnchor.constraint(equalToConstant: 35),
            planRouteButton.widthAnchor.constraint(equalToConstant: 80),
            planRouteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            planRouteButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
        ])
        planRouteButton.layer.cornerRadius = 10
        planRouteButton.clipsToBounds = true
    }
    
    func configureGoButton() {
        goButton.translatesAutoresizingMaskIntoConstraints = false
        goButton.backgroundColor = .systemGreen
        goButton.setTitleColor(UIColor.white, for: .normal)
        goButton.setTitle("Go", for: .normal)
        goButton.addTarget(self, action: #selector(goButtonTapped), for: .touchUpInside)
        NSLayoutConstraint.activate([
            goButton.heightAnchor.constraint(equalToConstant: 35),
            goButton.widthAnchor.constraint(equalToConstant: 80),
            goButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            goButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
        ])
        goButton.layer.cornerRadius = 10
        goButton.clipsToBounds = true
    }
    
    func configureETALabel() {
        etaLabel.translatesAutoresizingMaskIntoConstraints = false
        etaLabel.backgroundColor = .clear
        etaLabel.textAlignment = .center
        etaLabel.textColor = .systemGreen
        etaLabel.font = .boldSystemFont(ofSize: 16)
        etaLabel.numberOfLines = 0
        NSLayoutConstraint.activate([
            etaLabel.heightAnchor.constraint(equalToConstant: 70),
            etaLabel.leadingAnchor.constraint(equalTo: planRouteButton.trailingAnchor, constant: 1),
            etaLabel.trailingAnchor.constraint(equalTo: goButton.leadingAnchor, constant: -1),
            etaLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    func configureTextDirectionsButton() {
        textDirectionsButton.translatesAutoresizingMaskIntoConstraints = false
        textDirectionsButton.tintColor = .systemGreen
        textDirectionsButton.backgroundColor = .clear
        textDirectionsButton.setImage(UIImage(systemName: "info.circle.fill"), for: .normal)
        textDirectionsButton.addTarget(self, action: #selector(textDirectionsButtonTapped), for: .touchUpInside)
        NSLayoutConstraint.activate([
            textDirectionsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textDirectionsButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -55)
        ])
    }
    
    func configureSearchBar() {
        let searchBarTableView = SearchBarTableViewController()
        resultSearchController = UISearchController(searchResultsController : searchBarTableView)
        resultSearchController?.searchResultsUpdater = searchBarTableView as UISearchResultsUpdating
        searchBarTableView.mapView = mapView
        searchBarTableView.handleMapSearchDelegate = self
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for a place or address"
        navigationItem.titleView = resultSearchController?.searchBar
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
    }
    
    /// this will change
    
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
            // show alert letting user know they have to turn this on
        }
    }
    
    func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            startTrackingUserLocation()
        case .denied:
            // show alert instructing them to turn on permissions
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            // show an alert letting them know what's up
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
// this will change
extension MainMapViewController: MKMapViewDelegate {
        
    //will need a pic resizing function and pulling user image
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        switch annotation {
        // 1
        case let user as MKUserLocation:
            // 2
            if let existingView = mapView
                .dequeueReusableAnnotationView(withIdentifier: "profilepic") {
                return existingView
            } else {
                // 3
                let view = MKAnnotationView(annotation: user, reuseIdentifier: "profilepic")
                view.image = #imageLiteral(resourceName: "profilepic")
                view.layer.cornerRadius = view.frame.size.height/2
                view.layer.masksToBounds = true
        
                return view
            }
        default:
            return nil
        }
    }
    
    func showRouteOnMap(startCoordinate: CLLocationCoordinate2D, endCoordinate: CLLocationCoordinate2D) {
        let sourcePlacemark = MKPlacemark(coordinate: startCoordinate, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: endCoordinate, addressDictionary: nil)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let sourceAnnotation = MKPointAnnotation()
        
        if let location = sourcePlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
        }
        
        let destinationAnnotation = MKPointAnnotation()
        
        if let location = destinationPlacemark.location {
            destinationAnnotation.coordinate = location.coordinate
        }
                
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
        
        // Calculate the direction
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate {
            (response, error) -> Void in
            
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                
                return
            }
            let route = response.routes[0]
            self.mapView.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
            
            let etaMiles = (route.distance) * 0.000621
            let etaTime = (((route.expectedTravelTime) / 60) / 60)
            self.etaLabel.text = "Miles: \(Int(etaMiles)) mi.\n Time: \(String(format: "%.2f", etaTime)) hrs."
            
            self.locationManager.monitoredRegions.forEach({ self.locationManager.stopMonitoring(for: $0)})
            self.steps = route.steps
            for i in 0 ..< route.steps.count { // to show a mark at each step
                let step = route.steps[i]
                let region = CLCircularRegion(center: step.polyline.coordinate, radius: 20, identifier: "\(i)")
                self.locationManager.startMonitoring(for: region)
                let circle = MKCircle(center: region.center, radius: region.radius)
                self.mapView.addOverlay(circle)
            }
    }}
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
        let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .systemGreen
            renderer.lineWidth = 4.0
        
            return renderer
        }
        if overlay is MKCircle {
            let renderer = MKCircleRenderer(overlay: overlay)
            renderer.strokeColor = .systemBlue
            renderer.fillColor = .systemBlue
            renderer.alpha = 0.5
            return renderer
        }
        return MKOverlayRenderer()
    }
}
    protocol HandleMapSearch {
        func dropPinZoomIn(placemark: MKPlacemark)
    }

extension MainMapViewController : HandleMapSearch {
    
    func dropPinZoomIn(placemark: MKPlacemark) {
        //cache the pin
        selectedPin = placemark
        //clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.subtitle = "\(placemark.abbreviation)"
        mapView.addAnnotation(annotation)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
}
