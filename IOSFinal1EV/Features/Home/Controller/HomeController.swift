//
//  ViewController.swift
//  IOSFinal1EV
//
//  Created by Manu Espeso on 29/11/2019.
//  Copyright © 2019 Manu Espeso. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import FirebaseAuth
import CoreData

class HomeController: UIViewController {
    
    @IBOutlet weak var adressDirection: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var goButton: UIButton!
    @IBAction func goButtonTapped(_ sender: UIButton) {
        getDirections()
    }
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBAction func profileButton(_ sender: Any) {
        goToProfile()
    }
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        signOut()
    }
    
    let locationManager = CLLocationManager()
    let regionZoomMeters: Double = 7000
    var previusLocation: CLLocation?
    
    let geoCoder = CLGeocoder()
    var directionsArray: [MKDirections] = []
    
    var userEmail: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        userNameLabel.text = userEmail
        
        mapView.delegate = self
        goButton.layer.cornerRadius = goButton.frame.size.height/2
        checkLocationServices()
    }

    func goToProfile() {
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "ProfileController") as? ProfileController {
            
            controller.modalTransitionStyle = .flipHorizontal
            controller.userEmail = userEmail
            
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    
    func signOut() {
        let alert = UIAlertController(title: "Sign Out",
                                      message: "Are you sure do you want to Sign Out?",
                                      preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Cancel",
                                      style: UIAlertAction.Style.default,
                                      handler: nil))
        alert.addAction(UIAlertAction(title: "Sign Out",
                                      style: UIAlertAction.Style.destructive,
                                      handler: { action in
                                        do {
                                            try Auth.auth().signOut()
                                            if let controller = self.storyboard?.instantiateViewController(withIdentifier: "LoginController") as? LoginController {
                                                
                                                controller.modalTransitionStyle = .flipHorizontal
                                                controller.modalPresentationStyle = .fullScreen
                                                
                                                self.present(controller, animated: true, completion: nil)
                                            }
                                        } catch let err {
                                            print("Failed to sign out with error", err)
                                        }
        }))
        self.present(alert,
                     animated: true,
                     completion: nil)
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            //Show alert letting user kwon they have to turn location permissions on
        }
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            startTrakingUserLocation()
        case .denied:
            //Show alert instructing how to enable the location permissions
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            
        case .restricted:
            //Show a alert letting then what's up
            break
        case .authorizedAlways:
            break
        @unknown default:
            break
        }
    }
    
    func startTrakingUserLocation() {
        
        mapView.showsUserLocation = true
        
        centerViewOnUserLocation()
        
        locationManager.startUpdatingLocation()
        previusLocation = getCenterLocation(for: mapView)
    }
    
    func centerViewOnUserLocation() {
        
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionZoomMeters, longitudinalMeters: regionZoomMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    func getDirections() {
        guard let location = locationManager.location?.coordinate else {
            //TODO: Inform user we don´t have their current location
            return
        }
        
        let request = createDirectionsRequest(from: location)
        let directions = MKDirections(request: request)
        
        resetMapView(withNew: directions)
        
        directions.calculate{ [unowned self] (response, error) in
            guard let response = response else {return}
            
            for route in response.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
    }
    
    func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request {
        
        let destinationCoordinate = getCenterLocation(for: mapView).coordinate
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        
        return request
    }
    
    func resetMapView(withNew directions: MKDirections) {
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map { $0.cancel() }
    }
}

extension HomeController: CLLocationManagerDelegate {
    
    /*func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
     guard let location = locations.last else { return }
     let center = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
     let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionZoomMeters, longitudinalMeters: regionZoomMeters)
     
     mapView.setRegion(region, animated: true)
     }*/
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}

extension HomeController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        
        guard let previusLocation = self.previusLocation else {return}
        guard center.distance(from: previusLocation) > 50 else {return}
        self.previusLocation = center
        
        geoCoder.cancelGeocode()
        
        geoCoder.reverseGeocodeLocation(center) { [weak self] (placemarks, error) in
            guard let self = self else {return}
            
            if let _ = error {
                //TODO: Show alert informing the user
                return
            }
            
            guard let placemark = placemarks?.first else {
                //TODO: Show alert informing the user
                return
            }
            
            let streetNumber = placemark.subThoroughfare ?? ""
            let streetName = placemark.thoroughfare ?? ""
            
            DispatchQueue.main.async {
                self.adressDirection.text = "\(streetName) \(streetNumber)"
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .systemTeal
        
        return renderer
    }
}

