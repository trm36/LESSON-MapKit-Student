//
//  ViewController.swift
//  MapsCode
//
//  Created by Taylor Mott on 29-Aug-17.
//  Copyright © 2017 Mott Applications. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    // MARK: - PROPERTIES
    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    var routePolyline: MKPolyline?
    
    // MARK: - VIEW CONTROLLER LIFE CYCLE METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //each degree of lat ~69 miles
        //each degree of long depends on current latitude (range from 0-69 miles)
        let utahRegion = MKCoordinateRegion(center: utahCenterCoordinate(), span: MKCoordinateSpan(latitudeDelta: 6, longitudeDelta: 6))
        
        mapView.region = utahRegion
        
        for nationalPark in utahNationalParks() {
            let annonation = Annotation()
            annonation.coordinate = nationalPark.coordinate
            annonation.title = nationalPark.name
            mapView.addAnnotation(annonation)
        }
        
        let utahPolygon = MKPolygon(coordinates: utahCoordinates(), count: utahCoordinates().count)
        mapView.add(utahPolygon)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        askForLocationPermissions()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - TOOLBAR BUTTON METHODS
    @IBAction func showRouteButtonTapped() {
        getDrivingDirectionsFromCurrentLocation()
    }
    
    // MARK: - LOCATION MANAGER DELEGATE
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            manager.startUpdatingLocation()
            mapView.showsUserLocation = true
        }
    }
    
    // MARK: - MAP VIEW DELEGATE
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolygon {
            let render = MKPolygonRenderer(overlay: overlay)
            render.lineWidth = 1.5
            render.strokeColor = .blue
            return render
        } else if overlay is MKPolyline {
            let render = MKPolylineRenderer(overlay: overlay)
            render.lineWidth = 0.75
            render.strokeColor = .red
            return render
        } else {
            return MKOverlayRenderer()
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is Annotation {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "NPS")
            
            if let dequeuedAnnotationView = annotationView {
                dequeuedAnnotationView.annotation = annotation
            } else {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "NPS")
            }
            
            annotationView?.image = UIImage(named: "NPS")
            annotationView?.canShowCallout = true
            
            return annotationView
        }
        
        return nil
    }
    
    // MARK: - HELPER FUNCTIONS
    func askForLocationPermissions() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            mapView.showsUserLocation = true
        }
    }
    
    func getDrivingDirectionsFromCurrentLocation() {
        
        let drivingRouteRequest = MKDirectionsRequest()
        drivingRouteRequest.transportType = .automobile
        drivingRouteRequest.source = MKMapItem(placemark: MKPlacemark(coordinate: mapView.userLocation.coordinate))
        let zion = utahNationalParks()[0]
        drivingRouteRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate: zion.coordinate))
        
        let drivingRouteDirections = MKDirections(request: drivingRouteRequest)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        drivingRouteDirections.calculate { (response: MKDirectionsResponse?, error: Error?) in
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            
            guard let response = response else {
                print("\(String(describing: error?.localizedDescription))")
                return
            }
            
            guard let firstRoute = response.routes.first else {
                print("No Routes")
                return
            }
            
            if let routePolyline = self.routePolyline {
                self.mapView.remove(routePolyline)
            }
            
            self.routePolyline = firstRoute.polyline
            
            DispatchQueue.main.async {
                self.mapView.add(firstRoute.polyline)
            }
        }
    }
    
    // MARK: - COORDINATES
    func utahCoordinates() -> [CLLocationCoordinate2D] {
        
        /***********************************************
         
         0 -------- 1            0 - UT, ID, NV
         |          |            1 - UT, ID, WY
         |          |            2 - UT, WY
         |          2 ----- 3    3 - UT, WY, CO
         |                  |    4 - UT, CO, AZ, NM
         |                  |    5 - UT, NV, AZ
         |                  |
         |                  |
         |                  |
         |                  |
         |                  |
         |                  |
         5 ---------------- 4
         
         **********************************************/
        
        let point0 = CLLocationCoordinate2D(latitude: 41.99386, longitude: -114.04147)
        let point1 = CLLocationCoordinate2D(latitude: 42.00162, longitude: -111.04675)
        let point2 = CLLocationCoordinate2D(latitude: 40.99808, longitude: -111.04696)
        let point3 = CLLocationCoordinate2D(latitude: 41.00002, longitude: -109.05160)
        let point4 = CLLocationCoordinate2D(latitude: 36.99909, longitude: -109.04524)
        let point5 = CLLocationCoordinate2D(latitude: 37.00103, longitude: -114.05041)
        
        return [point0, point1, point2, point3, point4, point5]
    }
    
    func utahCenterCoordinate() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: 39.572317, longitude: -111.646970)
    }
    
    func utahNationalParks() -> [(name: String, coordinate: CLLocationCoordinate2D)] {
        let zion = (name: "Zion", coordinate: CLLocationCoordinate2D(latitude: 37.30, longitude: -113.05))
        let bryceCanyon = (name: "Bryce Canyon", coordinate: CLLocationCoordinate2D(latitude: 37.57, longitude: -112.18))
        let canyonlands = (name: "Canyonlands", coordinate: CLLocationCoordinate2D(latitude: 38.2, longitude: -109.93))
        let capitolReef = (name: "Capitol Reef", coordinate: CLLocationCoordinate2D(latitude: 38.2, longitude: -111.17))
        let arches = (name: "Arches", coordinate: CLLocationCoordinate2D(latitude: 38.68, longitude: -109.57))
        
        return [zion, bryceCanyon, canyonlands, capitolReef, arches]
    }
    
}

