//
//  ViewController.swift
//  TripPlanner
//
//  Created by Chris Withers on 3/8/21.
//
import CoreLocation
import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    //MARK: - Properties
    
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 10000
    var previousLocation: CLLocation?
    var mapView = MKMapView()
    let pin = UIImageView(image: #imageLiteral(resourceName: "icons8-map-pin-50-3"))
    let addressLabel = UILabel()
    let goButton = UIButton()
    let geoCoder = CLGeocoder()
    var directionsArray: [MKDirections] = []
    
    private var landmarks: [Landmark] = []
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray
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
    
    @objc func goButtonTapped(sender : UIButton) {
        getDirections()
    }
    
    
    //MARK: - Methods
    
    func allConfiguration() {
        configureMap()
        configurePin()
        configureAddressLabel()
        configureGoButton()
    }
    
    func addSubViews() {
        view.addSubview(mapView)
        view.addSubview(pin)
        view.addSubview(addressLabel)
        view.addSubview(goButton)
    }
    
    func configureMap() {
        // Set initial location in Santa Monica
        //        let initialLocation = CLLocation(latitude: 34.0195, longitude: -118.4912)
        //        mapView.centerToLocation(initialLocation)
        //        let smCenter = CLLocation(latitude: 34.0099, longitude: -118.4960)
        //        let region = MKCoordinateRegion(
        //            center: smCenter.coordinate,
        //            latitudinalMeters: 5000, //how constrained can users look in region
        //            longitudinalMeters: 6000)
        // camera boundary by city
        //        mapView.setCameraBoundary(
        //            MKMapView.CameraBoundary(coordinateRegion: region),
        //            animated: true)
        // zoom range by city
        //        let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 200000)
        //        mapView.setCameraZoomRange(zoomRange, animated: true)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
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
    
    func configurePin() {
        pin.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pin.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            pin.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pin.widthAnchor.constraint(equalToConstant: 40),
            pin.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func configureAddressLabel() {
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        addressLabel.backgroundColor = .white
        addressLabel.textColor = .black
        addressLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        addressLabel.textAlignment = .center
        NSLayoutConstraint.activate([
            addressLabel.heightAnchor.constraint(equalToConstant: 50),
            addressLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            addressLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            addressLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func configureGoButton() {
        goButton.translatesAutoresizingMaskIntoConstraints = false
        goButton.backgroundColor = .systemGreen
        goButton.setTitleColor(UIColor.white, for: .normal)
        goButton.setTitle("Go", for: .normal)
        goButton.addTarget(self, action: #selector(self.goButtonTapped), for: .touchUpInside)
        NSLayoutConstraint.activate([
            goButton.heightAnchor.constraint(equalToConstant: 30),
            goButton.leadingAnchor.constraint(equalTo: addressLabel.trailingAnchor, constant: -75),
            goButton.trailingAnchor.constraint(equalTo: addressLabel.trailingAnchor, constant: -10),
            goButton.bottomAnchor.constraint(equalTo: addressLabel.topAnchor, constant: -10),
        ])
        goButton.layer.cornerRadius = 10
        goButton.clipsToBounds = true
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
    
    func getDirections() {
        guard let location = locationManager.location?.coordinate else {
            //to do: inform user we dont have their current location
            return
        }
        
        let request = createDirectionsRequest(from: location)
        let directions = MKDirections(request: request)
        resetMapView(withNew: directions)
        
        directions.calculate { [unowned self] (response, error) in
            // todo: handle error if needed
            guard let response = response else { return } // to do: show response not available in an alert
            
            for route in response.routes {
                self.mapView.addOverlay(route.polyline) // lines connected
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true) // show route in the screen
            }
        }
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

extension ViewController: MKMapViewDelegate {
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
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        let geoCoder = CLGeocoder()
        
        guard let previousLocation = self.previousLocation else { return }
        guard center.distance(from: previousLocation) > 50 else { return }
        self.previousLocation = center
        
        geoCoder.cancelGeocode()
        
        geoCoder.reverseGeocodeLocation(center) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            
            if let _ = error {
                //todo: show alert informing user
                return
            }
            
            guard let placemark = placemarks?.first else {
                //todo: show alert informing user
                return
            }
            
            let streetNumber = placemark.subThoroughfare ?? ""
            let streetName = placemark.thoroughfare ?? ""
            
            DispatchQueue.main.async {
                self.addressLabel.text = "\(streetNumber) \(streetName)"
            }
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
