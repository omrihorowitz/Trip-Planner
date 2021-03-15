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
        addAllSubviews()
        addAllConfiguration()
        checkLocationServices()
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
    }
    
    func configureMapView() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
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
            planRouteButton.leadingAnchor.constraint(equalTo: view.trailingAnchor, constant: -150),
            planRouteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            planRouteButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
        ])
        planRouteButton.layer.cornerRadius = 10
        planRouteButton.clipsToBounds = true
    }
    
    func configureGoButton() {
        
    }
    
    func configureTripDetailLabel() {
        
    }
    
    func configureSearchBar() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.backgroundColor = .white
        searchBar.placeholder = "What do you want to find?"
//        searchBar.addTarget(self, action: #selector(searchBar), for: .touchUpInside)
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.topAnchor)
        ])
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
    
    //extension on searchbar
}
