//
//  MapViewController.swift
//  TripPlanner
//
//  Created by Chris Withers on 3/22/21.
//

import UIKit
import CoreLocation
import MapKit

protocol MapViewGoButtonPressedDelegate: AnyObject {
    
    func updateCoordinates(originLong: Double, originLat: Double, destinationLong: Double, destinationLat: Double)
    
}

class MapViewController: UIViewController, CLLocationManagerDelegate {

    //View items
    let locationManager = CLLocationManager()
    var userLocation: CLLocationCoordinate2D? = nil
    var currentPlace: CLPlacemark?
    var userPinView: MKAnnotationView!

    
    let originLocationLabel = TPTitleLabel(textAlignment: .center, fontSize: 16)
    let destinationLocationLabel = TPTitleLabel(textAlignment: .center, fontSize: 16)
    
    let originLocationSearchBar = UISearchBar()
    let destinationSearchBar = UISearchBar()
    
    let goButton = TPButton(backgroundColor: .systemGreen, title: "Go")
    
    let showOrHideSearchesButton = TPButton(backgroundColor: .systemPink, title: "-")
    
    let suggestionsTableView = UITableView()
    
    let map = MKMapView()
    
    let directionsButton = TPButton(backgroundColor: .systemGreen, title: " Detail Directions ")
    
    let searchStackView = UIStackView()
    
    let etaLabel = UILabel()
    
    //Delegates and data
    let cellID = "CellID"
    var matchingItems : [MKMapItem] = []
    var steps: [MKRoute.Step] = []
    
    var delegate: MapViewGoButtonPressedDelegate?
    
    var originLong: Double?
    var destinationLong: Double?
    
    var originLat: Double?
    var destinationLat: Double?
    
    var trip: Trip? {
        didSet {
            self.originLong = trip?.originLong
            self.originLat = trip?.originLat
            self.destinationLong = trip?.destinationLong
            self.destinationLat = trip?.destinationLat
            loadViewIfNeeded()
            goButtonTapped()
            updateOriginSearchBar()
            updateDestinationSearchBar()
            if trip?.owner != UserController.shared.currentUser?.email {
                goButton.isUserInteractionEnabled = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        originLocationSearchBar.delegate = self
        destinationSearchBar.delegate = self
        suggestionsTableView.delegate = self
        suggestionsTableView.dataSource = self
        map.delegate = self
        suggestionsTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        view.addSubviews(map, directionsButton)
        view.addSubviews(etaLabel)
        map.addSubview(searchStackView)
        map.addSubview(suggestionsTableView)
        constrainStackView()
        constrainMapView()
        constrainDirectionsButton()
        constrainSuggestionsTableView()
        constrainETALabel()
        addButtonTargets()
        
        
    }
    


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if trip == nil {
            if let originLong = originLong, let originLat = originLat, let destinationLong = destinationLong, let destinationLat = destinationLat {
                goButtonTapped()
                updateOriginSearchBar()
                updateDestinationSearchBar()
            }
        }
        
    }

    
    func updateOriginSearchBar() {
        
        guard let originLong = self.originLong, let originLat = self.originLat else { return }
        
        let origin = CLLocation(latitude: originLat, longitude: originLong)
    
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(origin) { [weak self] (placemarks, error) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if let _ = error {
                    self.originLocationSearchBar.text = "Unknown location"
                }
                if let placemark = placemarks?[0] {
                    let originName = placemark.locality
                    self.originLocationSearchBar.text = originName
                }
            }
        }
    }
    
    func updateDestinationSearchBar() {
        
        guard let destinationLong = self.destinationLong, let destinationLat = self.destinationLat else { return }
        
        let destination = CLLocation(latitude: destinationLat, longitude: destinationLong)
        
        
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(destination) { [weak self] (placemarks, error) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if let _ = error {
                    self.destinationSearchBar.text = "Unknown location"
                }
                
                if let placemark = placemarks?[0] {
                    let destinationName = placemark.locality
                    self.destinationSearchBar.text = destinationName
                }
            }
        }
    }
    
    @objc func goButtonTapped() {
        hideOrShowButtonTapped(sender: goButton)
        
        guard let originLat = originLat, let originLong = originLong, let destinationLat = destinationLat, let destinationLong = destinationLong else { return }
        
        map.removeAnnotations(map.annotations)
        map.removeOverlays(map.overlays)
        delegate?.updateCoordinates(originLong: originLong, originLat: originLat, destinationLong: destinationLong, destinationLat: destinationLat)
        
        let startCoordinate = CLLocationCoordinate2D(latitude: originLat, longitude: originLong)
        let endCoordinate = CLLocationCoordinate2D(latitude: destinationLat, longitude: destinationLong)
        
        let sourcePlacemark = MKPlacemark(coordinate: startCoordinate, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: endCoordinate, addressDictionary: nil)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let sourceAnnotation = MKPointAnnotation()
        
        sourceAnnotation.coordinate = sourcePlacemark.coordinate
        sourceAnnotation.subtitle = "Start"
    
        map.addAnnotation(sourceAnnotation)

        if let location = sourcePlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
        }

        let destinationAnnotation = MKPointAnnotation()
        
        destinationAnnotation.coordinate = destinationPlacemark.coordinate
        destinationAnnotation.subtitle = "Stop"
        map.addAnnotation(destinationAnnotation)

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
            self.steps = route.steps
            self.map.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)
            let rect = route.polyline.boundingMapRect
            self.map.setRegion(MKCoordinateRegion(rect), animated: true)
            
            let etaMiles = (route.distance) * 0.000621
            let etaTime = (((route.expectedTravelTime) / 60) / 60)
            self.etaLabel.text = "ETA\n Miles: \(String(format: "%.2f", etaMiles)) mi.\n Time: \(String(format: "%.2f", etaTime)) hrs."
            
            self.locationManager.monitoredRegions.forEach({ self.locationManager.stopMonitoring(for: $0)})
            self.steps = route.steps
            for i in 0 ..< route.steps.count { // to show a mark at each step
                let step = route.steps[i]
                let region = CLCircularRegion(center: step.polyline.coordinate, radius: 20, identifier: "\(i)")
                self.locationManager.startMonitoring(for: region)
                let circle = MKCircle(center: region.center, radius: region.radius)
                self.map.addOverlay(circle)
            }
    }
    }
    
    @objc func hideOrShowButtonTapped(sender: UIButton) {
        switch sender.titleLabel?.text {
        case "+":
            UIView.animate(withDuration: 0.5) {
                self.originLocationLabel.isHidden = false
                self.originLocationSearchBar.isHidden = false
                self.destinationLocationLabel.isHidden = false
                self.destinationSearchBar.isHidden = false
                self.goButton.isHidden = false
                sender.setTitle("-", for: .normal)
                sender.backgroundColor = .systemPink
            }
        case "-":
            UIView.animate(withDuration: 0.5) {
                self.originLocationLabel.isHidden = true
                self.originLocationSearchBar.isHidden = true
                self.destinationLocationLabel.isHidden = true
                self.destinationSearchBar.isHidden = true
                self.goButton.isHidden = true
                sender.setTitle("+", for: .normal)
                sender.backgroundColor = .systemGreen
            }
            
        case "Go" :
            UIView.animate(withDuration: 0.5) {
                self.originLocationLabel.isHidden = true
                self.originLocationSearchBar.isHidden = true
                self.destinationLocationLabel.isHidden = true
                self.destinationSearchBar.isHidden = true
                self.goButton.isHidden = true
                self.showOrHideSearchesButton.setTitle("+", for: .normal)
                self.showOrHideSearchesButton.backgroundColor = .systemGreen
            }
        default:
            break
        }
    }
    
    @objc func goToDirections() {
        
        let directionViewController = DirectionsTableViewController()
        directionViewController.modalPresentationStyle = .pageSheet
        directionViewController.steps = self.steps
        present(directionViewController, animated: true)
        
    }
    
    func addButtonTargets() {
        showOrHideSearchesButton.addTarget(self, action: #selector(hideOrShowButtonTapped(sender:)), for: .touchUpInside)
        goButton.addTarget(self, action: #selector(goButtonTapped), for: .touchUpInside)
        directionsButton.addTarget(self, action: #selector(goToDirections), for: .touchUpInside)
    }
    
    
    func constrainStackView() {
        
        searchStackView.translatesAutoresizingMaskIntoConstraints = false
        searchStackView.axis = .vertical
        searchStackView.distribution = .fillProportionally
        searchStackView.backgroundColor = .clear
        searchStackView.spacing = 5
        
        originLocationSearchBar.showsCancelButton = true
        destinationSearchBar.showsCancelButton = true
        
        originLocationSearchBar.backgroundImage = UIImage()
        destinationSearchBar.backgroundImage = UIImage()
        
        searchStackView.addArrangedSubview(originLocationLabel)
        searchStackView.addArrangedSubview(originLocationSearchBar)
        searchStackView.addArrangedSubview(destinationLocationLabel)
        searchStackView.addArrangedSubview(destinationSearchBar)
        searchStackView.addArrangedSubview(goButton)
        searchStackView.addArrangedSubview(showOrHideSearchesButton)
        
        originLocationLabel.text = "Origin"
        destinationLocationLabel.text = "Destination"
        
        NSLayoutConstraint.activate([
            searchStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 5),
            searchStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -5)
        ])
    }
    
    func constrainSuggestionsTableView() {
        
        suggestionsTableView.translatesAutoresizingMaskIntoConstraints = false
        
        suggestionsTableView.isHidden = true
        
        NSLayoutConstraint.activate([
            suggestionsTableView.topAnchor.constraint(equalTo: searchStackView.bottomAnchor),
            suggestionsTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            suggestionsTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            suggestionsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        
        ])
        
    }
    
    func constrainMapView() {
        
        map.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            map.topAnchor.constraint(equalTo: view.topAnchor),
            map.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            map.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            map.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
    }
    
    func constrainDirectionsButton() {
        directionsButton.sizeToFit()
        NSLayoutConstraint.activate([
            directionsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -13),
            directionsButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40)
        ])
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
        let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .systemBlue
            renderer.lineWidth = 4.0
        
            return renderer
        }
        if overlay is MKCircle {
            let renderer = MKCircleRenderer(overlay: overlay)
            renderer.strokeColor = .systemYellow
            renderer.fillColor = .systemYellow
            renderer.alpha = 0.5
            return renderer
        }
        return MKOverlayRenderer()
    }

    func constrainETALabel() {
        etaLabel.translatesAutoresizingMaskIntoConstraints = false
        etaLabel.backgroundColor = .white
        etaLabel.textAlignment = .center
        etaLabel.textColor = .systemGreen
        etaLabel.font = .boldSystemFont(ofSize: 18)
        etaLabel.numberOfLines = 0
        etaLabel.layer.cornerRadius = 10
        etaLabel.clipsToBounds = true
        NSLayoutConstraint.activate([
            etaLabel.heightAnchor.constraint(equalToConstant: 80),
            etaLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 60),
            etaLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -160),
            etaLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 10)
        ])
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
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
        map.showsUserLocation = true
        locationManager.startUpdatingLocation()
    }
}

extension MapViewController : UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        suggestionsTableView.isHidden = false
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        suggestionsTableView.isHidden = true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        suggestionsTableView.isHidden = false
        
        guard let searchBarText = searchBar.text else {return}
        
        let request = MKLocalSearch.Request()
        
        request.naturalLanguageQuery = searchBarText
        request.region = map.region
        
        let search = MKLocalSearch(request: request)
        
        search.start { (response, error) in
            guard let response = response else {return}
            
            self.matchingItems = response.mapItems
            self.suggestionsTableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}

extension MapViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: cellID)
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.detailTextLabel?.text = parseAddress(selectedItem: selectedItem)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingItems[indexPath.row].placemark
        if originLocationSearchBar.isFirstResponder {
            originLocationSearchBar.text = selectedItem.name
            originLat = selectedItem.coordinate.latitude
            originLong = selectedItem.coordinate.longitude
        } else if destinationSearchBar.isFirstResponder {
            destinationSearchBar.text = selectedItem.name
            destinationLat = selectedItem.coordinate.latitude
            destinationLong = selectedItem.coordinate.longitude
        }
        suggestionsTableView.isHidden = true
    }
    
    func parseAddress(selectedItem: MKPlacemark) -> String {
        
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " ": ""
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", ": ""
        
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " ": ""
        
        let addressLine = String(
            format: "%@%@%@%@%@%@%@%@",
            //street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            //city
            selectedItem.locality ?? "",
            comma,
            secondSpace,
            //state
            selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }
}

extension MapViewController : MKMapViewDelegate {
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let identifier = "MyPin"

        if annotation is MKUserLocation {
            let pin = mapView.view(for: annotation) ?? MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
             pin.image = UIImage(named: "orangutan")
             userPinView = pin
             return pin
         }

        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            annotationView?.image = UIImage(named: "pin.png")

        } else {
            annotationView?.annotation = annotation
        }
        return annotationView
    }
}
