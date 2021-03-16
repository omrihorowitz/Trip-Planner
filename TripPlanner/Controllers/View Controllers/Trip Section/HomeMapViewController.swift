//
//  HomeMapViewController.swift
//  TripPlanner
//
//  Created by Omri Horowitz on 3/16/21.
//
import MapKit
import UIKit
import CoreLocation

class HomeMapViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate, MKLocalSearchCompleterDelegate {
    
    //MARK: - Properties
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 10000
    var previousLocation: CLLocation?
    let geoCoder = CLGeocoder()
    var directionsArray: [MKDirections] = []
    private let completer = MKLocalSearchCompleter()
    private var currentRegion: MKCoordinateRegion?
    
    //MARK: - Outlets
    
    @IBOutlet weak var searchBar: UISearchBar!
    //show suggestions
    //press suggestions for autocomplete
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var etaLabel: UILabel!
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServices()
        addCancelKeyboardGestureRecognizer()
        completer.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
      }
    
    //MARK: - Actions

    
    @IBAction func planRouteButtonTapped(_ sender: Any) {
        //        resetMapView(withNew: MKDirections) //tbd
        let tripDetailViewController = TripDetailViewController()
        present(tripDetailViewController, animated: true)
    }
    
    @IBAction func goButtonTapped(_ sender: Any) {
        //        resetMapView(withNew: MKDirections) //tbd
        //mapping the route from user to the selected pin
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
    
    //extension MainMapViewController: MKMapViewDelegate {
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
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
      guard let firstResult = completer.results.first else {
        return
      }
      
  //    showSuggestion(firstResult.title) // write this function
    }
    
    func completer(
      _ completer: MKLocalSearchCompleter,
      didFailWithError error: Error
    ) {
      print("Error suggesting a location: \(error.localizedDescription)")
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

extension UIViewController {
    func addCancelKeyboardGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
