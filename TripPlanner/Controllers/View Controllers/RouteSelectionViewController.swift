

import UIKit
import MapKit
import CoreLocation

class RouteSelectionViewController: UIViewController {
    
    //MARK: - Properties
    
    let titleLabel = UILabel()
    let inputContainerView = UIView()
    let originLabel = UILabel()
    let originTextField = UITextField()
    let stopLabel = UILabel()
    let stopTextField = UITextField()
    let extraStopLabel = UILabel()
    let extraStopTextField = UITextField()
    let calculateButton = UIButton()
    let activityIndicatorView = UIActivityIndicatorView()
    let suggestionTitleLabel = UILabel()
    let suggestionLabel = UILabel()
    let suggestionContainerView = UIView()
    
    private var editingTextField: UITextField?
    private var currentRegion: MKCoordinateRegion?
    private var currentPlace: CLPlacemark?
    
    private let locationManager = CLLocationManager()
    private let completer = MKLocalSearchCompleter()
    
    private let defaultAnimationDuration: TimeInterval = 0.25
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addSubViews()
        allConfiguration()
        completer.delegate = self
        beginObserving()
        attemptLocationAccess()
        addCancelKeyboardGestureRecognizer()
    }
    
    // MARK: - Helpers
    
    func allConfiguration() {
        calculateButton.stylize()
//        configureGestures()
        configureTextFields()
        configureInputContainerView()
        configureOriginTextField()
        configureStopTextField()
        configureExtraStopTextField()
        configureCalculateButton()
        configureActivityIndicatorView()
        configureSuggestionTitleLabel()
        configureSuggestionLabel()
        configureSuggestionContainerView()
        configureTitleLabel()
        configureOriginLabel()
        configureStopLabel()
        configureExtraStopLabel()
    }
    
    func addSubViews() {
        view.addSubview(inputContainerView)
        view.addSubview(originTextField)
        view.addSubview(stopTextField)
        view.addSubview(extraStopTextField)
        view.addSubview(calculateButton)
        view.addSubview(activityIndicatorView)
        view.addSubview(suggestionTitleLabel)
        view.addSubview(suggestionLabel)
        view.addSubview(suggestionContainerView)
        view.addSubview(titleLabel)
        view.addSubview(originLabel)
        view.addSubview(stopLabel)
        view.addSubview(extraStopLabel)
    }
    
//    private func configureGestures() {
//        view.addGestureRecognizer(
//            UITapGestureRecognizer(
//                target: self,
//                action: #selector(handleTap(_:))
//            )
//        )
//        suggestionContainerView.addGestureRecognizer(
//            UITapGestureRecognizer(
//                target: self,
//                action: #selector(suggestionTapped(_:))
//            )
//        )
//    }
    
    private func configureTextFields() {
        originTextField.delegate = self
        stopTextField.delegate = self
        extraStopTextField.delegate = self
        
        originTextField.addTarget(
            self,
            action: #selector(textFieldDidChange(_:)),
            for: .editingChanged
        )
        stopTextField.addTarget(
            self,
            action: #selector(textFieldDidChange(_:)),
            for: .editingChanged
        )
        extraStopTextField.addTarget(
            self,
            action: #selector(textFieldDidChange(_:)),
            for: .editingChanged
        )
    }
    
    func configureInputContainerView() {
        inputContainerView.translatesAutoresizingMaskIntoConstraints = false
        inputContainerView.backgroundColor = .lightGray
        inputContainerView.layer.borderWidth = 0

        NSLayoutConstraint.activate([
        inputContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
        inputContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
        inputContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        inputContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -200),
        ])
    }
    
    func configureOriginTextField() {
        originTextField.translatesAutoresizingMaskIntoConstraints = false
        originTextField.placeholder = "Origin Address"
        originTextField.textColor = .black
        originTextField.backgroundColor = .white
        originTextField.font = UIFont(name: "NotoSansMyanmar", size: 15)
        
        NSLayoutConstraint.activate([
            originTextField.topAnchor.constraint(equalTo: originLabel.bottomAnchor, constant: 5),
            originTextField.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor, constant: 25),
            originTextField.trailingAnchor.constraint(equalTo: inputContainerView.trailingAnchor, constant: -25),
            originTextField.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    func configureStopTextField() {
        stopTextField.translatesAutoresizingMaskIntoConstraints = false
        stopTextField.placeholder = "End Address"
        stopTextField.textColor = .black
        stopTextField.backgroundColor = .white
        stopTextField.font = UIFont(name: "NotoSansMyanmar", size: 15)
        
        NSLayoutConstraint.activate([
            stopTextField.topAnchor.constraint(equalTo: stopLabel.bottomAnchor, constant: 5),
            stopTextField.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor, constant: 25),
            stopTextField.trailingAnchor.constraint(equalTo: inputContainerView.trailingAnchor, constant: -25),
            stopTextField.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    func configureExtraStopTextField() {
        extraStopTextField.translatesAutoresizingMaskIntoConstraints = false
        extraStopTextField.placeholder = "Extra Address"
        extraStopTextField.textColor = .black
        extraStopTextField.backgroundColor = .white
        extraStopTextField.font = UIFont(name: "NotoSansMyanmar", size: 15)
        
        NSLayoutConstraint.activate([
            extraStopTextField.topAnchor.constraint(equalTo: extraStopLabel.bottomAnchor, constant: 5),
            extraStopTextField.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor, constant: 25),
            extraStopTextField.trailingAnchor.constraint(equalTo: inputContainerView.trailingAnchor, constant: -25),
            extraStopTextField.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    func configureCalculateButton() {
        calculateButton.translatesAutoresizingMaskIntoConstraints = false
        calculateButton.backgroundColor = .systemGreen
        calculateButton.setTitleColor(UIColor.white, for: .normal)
        calculateButton.setTitle("Calculate", for: .normal)
        calculateButton.addTarget(self, action: #selector(calculateButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            calculateButton.topAnchor.constraint(equalTo: inputContainerView.bottomAnchor, constant: -40),
            calculateButton.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor, constant: 100),
            calculateButton.trailingAnchor.constraint(equalTo: inputContainerView.trailingAnchor, constant: -100)
        ])
        calculateButton.layer.cornerRadius = 10
        calculateButton.clipsToBounds = true
    }
    
    func configureActivityIndicatorView() {
        activityIndicatorView.style = .medium
        activityIndicatorView.contentMode = .scaleToFill
        
        NSLayoutConstraint.activate([
            activityIndicatorView.leadingAnchor.constraint(equalTo: calculateButton.trailingAnchor)
        ])
    }
    
    func configureSuggestionLabel() {
        suggestionLabel.translatesAutoresizingMaskIntoConstraints = false
        suggestionLabel.backgroundColor?.withAlphaComponent(0)
        suggestionLabel.textColor = .black
        suggestionLabel.font = UIFont(name: "NotoSansMyanmar-Bold", size: 15)
        suggestionLabel.text = "Address suggestion"
        
        NSLayoutConstraint.activate([
            suggestionLabel.topAnchor.constraint(equalTo: suggestionTitleLabel.topAnchor, constant: 40),
            suggestionLabel.leadingAnchor.constraint(equalTo: suggestionTitleLabel.leadingAnchor),
            suggestionLabel.trailingAnchor.constraint(equalTo: suggestionTitleLabel.trailingAnchor)
        ])
    }
    
    func configureSuggestionTitleLabel() {
        suggestionTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        suggestionTitleLabel.backgroundColor?.withAlphaComponent(0)
        suggestionTitleLabel.textColor = .black
        suggestionTitleLabel.font = UIFont(name: "NotoSansMyanmar-Bold", size: 20)
        suggestionTitleLabel.text = "Did you mean:"
        
        NSLayoutConstraint.activate([
            suggestionTitleLabel.topAnchor.constraint(equalTo: suggestionContainerView.topAnchor),
            suggestionTitleLabel.leadingAnchor.constraint(equalTo: suggestionContainerView.leadingAnchor, constant: 25),
            suggestionTitleLabel.trailingAnchor.constraint(equalTo: suggestionContainerView.trailingAnchor, constant: -25)
        ])
    }
    
    func configureSuggestionContainerView() {
        suggestionContainerView.translatesAutoresizingMaskIntoConstraints = false
        suggestionContainerView.backgroundColor = .lightGray
        suggestionContainerView.layer.borderWidth = 0

        NSLayoutConstraint.activate([
        suggestionContainerView.trailingAnchor.constraint(equalTo: inputContainerView.trailingAnchor, constant: -30),
        suggestionContainerView.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor, constant: 30),
            suggestionContainerView.topAnchor.constraint(equalTo: inputContainerView.bottomAnchor, constant: 10)
        ])
    }
    
    func configureTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.backgroundColor = .white
        titleLabel.textColor = .black
        titleLabel.font = UIFont(name: "NotoSansMyanmar-Bold", size: 20)
        titleLabel.textAlignment = .center
        titleLabel.text = "Plan Your Next Route!"
        
        NSLayoutConstraint.activate([
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: -25),
            titleLabel.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor, constant: 10)
        ])
    }
    
    func configureOriginLabel() {
        originLabel.translatesAutoresizingMaskIntoConstraints = false
        originLabel.backgroundColor = .lightGray
        originLabel.textColor = .black
        originLabel.font = UIFont(name: "NotoSansMyanmar-Bold", size: 15)
        originLabel.text = "Start Point"
        
        NSLayoutConstraint.activate([
            originLabel.topAnchor.constraint(equalTo: inputContainerView.topAnchor, constant: 25),
            originLabel.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor, constant: 25)
        ])
    }
    
    func configureStopLabel() {
        stopLabel.translatesAutoresizingMaskIntoConstraints = false
        stopLabel.backgroundColor = .lightGray
        stopLabel.textColor = .black
        stopLabel.font = UIFont(name: "NotoSansMyanmar-Bold", size: 15)
        stopLabel.text = "End Point"

        NSLayoutConstraint.activate([
            stopLabel.topAnchor.constraint(equalTo: extraStopTextField.bottomAnchor, constant: 25),
            stopLabel.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor, constant: 25)
        ])
    }
    
    func configureExtraStopLabel() {
        extraStopLabel.translatesAutoresizingMaskIntoConstraints = false
        extraStopLabel.backgroundColor = .lightGray
        extraStopLabel.textColor = .black
        extraStopLabel.font = UIFont(name: "NotoSansMyanmar-Bold", size: 15)
        extraStopLabel.text = "Extra Stop?"
        
        NSLayoutConstraint.activate([
            extraStopLabel.topAnchor.constraint(equalTo: originTextField.bottomAnchor, constant: 25),
            extraStopLabel.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor, constant: 25)
        ])
    }
    
    private func attemptLocationAccess() {
        guard CLLocationManager.locationServicesEnabled() else {
            return
        }
        
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.delegate = self
        
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else {
            locationManager.requestLocation()
        }
    }
    
    //not working currently...workign to translate to programattic
    private func hideSuggestionView(animated: Bool) {
        NSLayoutConstraint.activate([
            suggestionContainerView.topAnchor.constraint(equalTo: inputContainerView.bottomAnchor, constant: -1 * (suggestionContainerView.bounds.height + 1))
        ])
        
        guard animated else {
            view.layoutIfNeeded()
            return
        }
        
        UIView.animate(withDuration: defaultAnimationDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    //not working currently...workign to translate to programattic
    private func showSuggestion(_ suggestion: String) {
        suggestionLabel.text = suggestion
        NSLayoutConstraint.activate([
            suggestionContainerView.topAnchor.constraint(equalTo: inputContainerView.bottomAnchor, constant: -4)
        ])
   
        UIView.animate(withDuration: defaultAnimationDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func presentAlert(message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        
        present(alertController, animated: true)
    }
    
    // MARK: - Actions
    
    @objc private func textFieldDidChange(_ field: UITextField) {
        if field == originTextField && currentPlace != nil {
            currentPlace = nil
            field.text = ""
        }
        
        guard let query = field.contents else {
            hideSuggestionView(animated: true)
            
            if completer.isSearching {
                completer.cancel()
            }
            return
        }
        
        completer.queryFragment = query
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        let gestureView = gesture.view
        let point = gesture.location(in: gestureView)
        
        guard
            let hitView = gestureView?.hitTest(point, with: nil),
            hitView == gestureView
        else {
            return
        }
        
        view.endEditing(true)
    }
    
//    @objc func suggestionTapped(_ gesture: UITapGestureRecognizer) {
//        hideSuggestionView(animated: true)
//
//        editingTextField?.text = suggestionLabel.text
//        editingTextField = nil
//    }
    /// code to populate the text field with the suggestion
    
    @objc func calculateButtonTapped(sender : UIButton!) {
        view.endEditing(true)
        
        calculateButton.isEnabled = false
        activityIndicatorView.startAnimating()
        
        let segment: RouteBuilder.Segment?
        if let currentLocation = currentPlace?.location {
            segment = .location(currentLocation)
        } else if let originValue = originTextField.contents {
            segment = .text(originValue)
        } else {
            segment = nil
        }
        
        let stopSegments: [RouteBuilder.Segment] = [
            stopTextField.contents,
            extraStopTextField.contents
        ]
        .compactMap { contents in
            if let value = contents {
                return .text(value)
            } else {
                return nil
            }
        }
        
        guard
            let originSegment = segment,
            !stopSegments.isEmpty
        else {
            presentAlert(message: "Cannot calculate without origin and final destionation.")
            activityIndicatorView.stopAnimating()
            calculateButton.isEnabled = true
            return
        }
        
        RouteBuilder.buildRoute(
            origin: originSegment,
            stops: stopSegments,
            within: currentRegion
        ) { result in
            self.calculateButton.isEnabled = true
            self.activityIndicatorView.stopAnimating()
            
            switch result {
            case .success(let route):
                let viewController = DirectionsViewController(route: route)
                self.present(viewController, animated: true)
                
            case .failure(let error):
                let errorMessage: String
                
                switch error {
                case .invalidSegment(let reason):
                    errorMessage = "There was an error with: \(reason)."
                }
                
                self.presentAlert(message: errorMessage)
            }
        }
    }
    
    // MARK: - Notifications
    
    private func beginObserving() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardFrameChange(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }
    
    @objc private func handleKeyboardFrameChange(_ notification: Notification) {
        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        let viewHeight = view.bounds.height - view.safeAreaInsets.bottom
        let visibleHeight = (viewHeight - frame.origin.y) + 32
        
        UIView.animate(withDuration: defaultAnimationDuration) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - UITextFieldDelegate

extension RouteSelectionViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        hideSuggestionView(animated: true)
        
        if completer.isSearching {
            completer.cancel()
        }
        
        editingTextField = textField
    }
}

// MARK: - CLLocationManagerDelegate

extension RouteSelectionViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else {
            return
        }
        
        manager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let firstLocation = locations.first else {
            return
        }
        
        let commonDelta: CLLocationDegrees = 25 / 111 // 1/111 = 1 latitude km
        let span = MKCoordinateSpan(latitudeDelta: commonDelta, longitudeDelta: commonDelta)
        let region = MKCoordinateRegion(center: firstLocation.coordinate, span: span)
        
        currentRegion = region
        completer.region = region
        
        CLGeocoder().reverseGeocodeLocation(firstLocation) { places, _ in
            guard let firstPlace = places?.first, self.originTextField.contents == nil else {
                return
            }
            
            self.currentPlace = firstPlace
            self.originTextField.text = firstPlace.abbreviation
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error requesting location: \(error.localizedDescription)")
    }
}

// MARK: - MKLocalSearchCompleterDelegate

extension RouteSelectionViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        guard let firstResult = completer.results.first else {
            return
        }
        
        showSuggestion(firstResult.title)
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Error suggesting a location: \(error.localizedDescription)")
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
