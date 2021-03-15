//
//  ViewController.swift
//  TripPlanner
//
//  Created by Chris Withers on 3/8/21.
//
import CoreLocation
import UIKit
import MapKit

class AnnotatedMapViewController: UIViewController, CLLocationManagerDelegate {
    
    //MARK: - Properties
    
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 10000
    var previousLocation: CLLocation?
    var mapView = MKMapView()
    let planRouteButton = UIButton()
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
    
    //MARK: - Methods
    
    func allConfiguration() {
        configureMap()
        configurePlanRouteButton()
    }
    
    func addSubViews() {
        view.addSubview(mapView)
        view.addSubview(planRouteButton)
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
        planRouteButton.setTitle("Plan Route", for: .normal)
        planRouteButton.addTarget(self, action: #selector(planRouteButtonTapped), for: .touchUpInside)
        NSLayoutConstraint.activate([
            planRouteButton.heightAnchor.constraint(equalToConstant: 30),
            planRouteButton.leadingAnchor.constraint(equalTo: view.trailingAnchor, constant: -150),
            planRouteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            planRouteButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
        ])
        planRouteButton.layer.cornerRadius = 10
        planRouteButton.clipsToBounds = true
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

extension AnnotatedMapViewController: MKMapViewDelegate {
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
