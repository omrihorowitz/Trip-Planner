//
//  MapView.swift
//  TripPlanner
//
//  Created by Omri Horowitz on 3/15/21.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    
    @EnvironmentObject var mapData: MapViewModel
    
    func makeCoordinator() -> Coordinator {
        return MapView.Coordinator()
    }
    
    func makeUIView(context: Context) -> MKMapView {
        
        let view = mapData.mapView
        
        view.showsUserLocation = true
        view.delegate = context.coordinator
        
        return view
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        
    }
    
    Class Coordinator: NSObject, MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotion: MKAnnotation) -> MKAnnotationView? {
    
    if annotation.isKind(of: MKUserLocation.self){return nil}
    else{
    let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "PIN_View")
    pinAnnotation.tintColor = .red
    pinAnnotation.animatesDrop = true
    pinAnnotation.canShowCallout = true
    
    return pinAnnotation
    }
    }
    }
}
