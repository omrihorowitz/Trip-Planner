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
    
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 10000
    var previousLocation: CLLocation?
    var mapView = MKMapView()
    let pin = UIImageView(image: #imageLiteral(resourceName: "icons8-map-pin-50-3"))
    let addressLabel = UILabel()
    
    private var landmarks: [Landmark] = []
    
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
    
    func allConfiguration() {
        configureMap()
        configurePin()
        configureAddressLabel()
    }
    
    func addSubViews() {
        view.addSubview(mapView)
        view.addSubview(pin)
        view.addSubview(addressLabel)
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
}

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
        _ mapView: MKMapView,
        annotationView view: MKAnnotationView,
        calloutAccessoryControlTapped control: UIControl
    ) {
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
}
