//
//  ViewController.swift
//  TripPlanner
//
//  Created by Chris Withers on 3/8/21.
//
import CoreLocation
import UIKit
import MapKit

class MainMapViewController: UIViewController, CLLocationManagerDelegate {
    
    //MARK: - Properties
    
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 10000
    var previousLocation: CLLocation?
    var mapView = MKMapView()
    let etaLabel = UILabel()
    let goButton = UIButton()
    let searchBar = UISearchBar()
    let planRouteButton = UIButton()
    let textDirectionsButton = UIButton()
    let geoCoder = CLGeocoder()
    var directionsArray: [MKDirections] = []
    private var landmarks: [Landmark] = []
    
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
        //mapping from user to the pin
    }
    
    @objc func textDirectionsButtonTapped(sender : UIButton!) {
        let textDirectionsTableViewController = TextDirectionsTableViewController()
        present(textDirectionsTableViewController, animated: true)
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
        view.addSubview(searchBar)
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
        mapView.register(
            LandmarkView.self,
            forAnnotationViewWithReuseIdentifier:
                MKMapViewDefaultAnnotationViewReuseIdentifier)  // would need unique identifier w more classes
        loadInitialData()
        mapView.addAnnotations(landmarks)
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
        etaLabel.backgroundColor = .white
        etaLabel.textAlignment = .center
        etaLabel.textColor = .black
        etaLabel.text = "ETA: Mileage, Timing"
        NSLayoutConstraint.activate([
            etaLabel.heightAnchor.constraint(equalToConstant: 70),
            etaLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            etaLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
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
            textDirectionsButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -45)
        ])
    }
    
    func configureSearchBar() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.barStyle = .default
        searchBar.searchBarStyle = .minimal
        searchBar.isTranslucent = true
        searchBar.placeholder = "Search for a place or address"
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func loadInitialData() {
        // 1
        guard
            let fileName = Bundle.main.url(forResource: "HistoricLandmarks", withExtension: "geojson"),
            let artworkData = try? Data(contentsOf: fileName)
        else {
            return
        }
        
        do {
            // 2
            let features = try MKGeoJSONDecoder()
                .decode(artworkData)
                .compactMap { $0 as? MKGeoJSONFeature }
            // 3
            let validWorks = features.compactMap(Landmark.init)
            // 4
            landmarks.append(contentsOf: validWorks)
        } catch {
            // 5
            print("Unexpected error: \(error).")
        }
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
    
    func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request {
        let destinationCoordinate       = getCenterLocation(for: mapView).coordinate //this is where the pin is
        let startingLocation            = MKPlacemark(coordinate: coordinate) //user location
        let destination                 = MKPlacemark(coordinate: destinationCoordinate) // coordinate from destinationcoordinate
        
        let request                     = MKDirections.Request() // this is how you request directions
        request.source                  = MKMapItem(placemark: startingLocation)
        request.destination             = MKMapItem(placemark: destination)
        request.transportType           = .automobile
        request.requestsAlternateRoutes = false //switch later for alternate routes
        
        return request
    }
    
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
    func mapView(
        _ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        guard let landmark = view.annotation as? Landmark else {
            return
        }
        
        let launchOptions = [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ]
        landmark.mapItem?.openInMaps(launchOptions: launchOptions)
    }
        
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
}
