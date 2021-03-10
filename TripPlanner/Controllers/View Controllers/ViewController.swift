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
    
    var locationManager: CLLocationManager!
    var mapView = MKMapView()
    private var landmarks: [Landmark] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        addSubViews()
        allConfiguration()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func allConfiguration() {
        configureMap()
    }
    
    func addSubViews() {
        view.addSubview(mapView)
    }
    
    func configureMap() {
        // Set initial location in Santa Monica
        let initialLocation = CLLocation(latitude: 34.0195, longitude: -118.4912)
        mapView.centerToLocation(initialLocation)
        let smCenter = CLLocation(latitude: 34.0099, longitude: -118.4960)
        let region = MKCoordinateRegion(
            center: smCenter.coordinate,
            latitudinalMeters: 5000, //how constrained can users look in region
            longitudinalMeters: 6000)
        mapView.setCameraBoundary(
            MKMapView.CameraBoundary(coordinateRegion: region),
            animated: true)
        
        let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 200000)
        mapView.setCameraZoomRange(zoomRange, animated: true)
        let leftMargin:CGFloat = 0
        let topMargin:CGFloat = 0
        let mapWidth:CGFloat = view.frame.size.width
        let mapHeight:CGFloat = view.frame.size.height
        mapView.frame = CGRect(x: leftMargin, y: topMargin, width: mapWidth, height: mapHeight)
        mapView.mapType = MKMapType.mutedStandard //diff map types
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        //        mapView.center = view.center
        mapView.delegate = self
        mapView.register(
            LandmarkView.self,
            forAnnotationViewWithReuseIdentifier:
                MKMapViewDefaultAnnotationViewReuseIdentifier)  // would need unique identifier w more classes
        loadInitialData()
        mapView.addAnnotations(landmarks)
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
}

private extension MKMapView {
    func centerToLocation(
        _ location: CLLocation,
        regionRadius: CLLocationDistance = 1000
    ) {
        let coordinateRegion = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: regionRadius, //defauly 1k meters
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
}
