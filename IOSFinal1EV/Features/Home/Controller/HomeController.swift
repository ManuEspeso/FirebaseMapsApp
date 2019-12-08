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
    @IBAction func profileButton(_ sender: Any) {
        goToProfile()
    }
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        signOut()
    }
    
    let locationManager = CLLocationManager()
    let regionZoomMeters: Double = 4000
    var previusLocation: CLLocation?
    
    let geoCoder = CLGeocoder()
    var directionsArray: [MKDirections] = []
    
    var db: Firestore!
    var userEmail: String = ""
    var userName: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        
        getEmailFromCoreData()
        
        mapView.delegate = self
        goButton.layer.cornerRadius = goButton.frame.size.height/2
        checkLocationServices()
    }
    //Set in to the UINavigationController a label in the center who contains the userName
    override func viewDidAppear(_ animated: Bool) {
        
        let label = UILabel(frame: CGRect(x: 10, y: 0, width: 50, height: 40))
        label.font = UIFont.boldSystemFont(ofSize: 17)
        
        label.text = userName
        label.numberOfLines = 2
        label.textColor = .white
        label.sizeToFit()
        label.textAlignment = .center

        self.navigationItem.titleView = label
    }
    //In this method I'm taking the email from coredata to later check this email(user) in the Firebase database
    func getEmailFromCoreData() {
        let context = PersistenceService.context
        let fechtRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Usuarios")
        
        do {
            let result = try context.fetch(fechtRequest)
            
            for data in result as! [NSManagedObject] {
                //Save the email from coredata into a variable for do the check later
                userEmail = data.value(forKey: "email") as! String
            }
            //When all the code for get the email from coredata it's ok call the method for get datas from firebase database
            setUserNameTitle()
        } catch {
            print("ERROR, SOMETHING WRONG")
        }
    }
    //Get the userName from the Firebase database for insert this value in to the label in the UINavigationController
    func setUserNameTitle() {
        db.collection("users").whereField("email", isEqualTo: userEmail)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        let usernameFirebase = document.data().index(forKey: "username")
                        let usernameValue = document.data()[usernameFirebase!].value as! String
                        //Save the userName from the database in a variable who i'm calling avery time that the view is appear(viewDidAppear)
                        self.userName = usernameValue
                    }
                    
                }
        }
    }
    //This method if the same if I create a segue in the storyboard but how i don't now set a condicion in a segue for run it i prefer create it manualy and call it when needed
    func goToProfile() {
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "ProfileController") as? ProfileController {
            
            controller.modalTransitionStyle = .flipHorizontal
            controller.userEmail = userEmail
            
            self.present(controller, animated: true, completion: nil)
        }
    }
    //This method it's a easy form to create a alert. I'm create this alert for when you select the button to logOut alert if you are sure to close your session and delete your datas from the core data
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
                                            //Sign out the session in Firebase
                                            try Auth.auth().signOut()
                                            //Delete user datas from the core data
                                            self.deleteDataFromCoreData()
                                            //Segue for go to the Login View
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
    //This method is call it when the user log out and delete all the user elements in core data
    func deleteDataFromCoreData() {
        let context = PersistenceService.context
        let fechtRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Usuarios")
        
        do {
            let test = try context.fetch(fechtRequest)
            
            if (!test.isEmpty) {
                let objectToDelete = test[0] as! NSManagedObject
                context.delete(objectToDelete)
            }
            do {
                try context.save()
            }
            catch {
                print(error)
            }
        }
        catch {
            print(error)
        }
    }
    //This method check if the location services is enabled for can offer the maps services
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            //Show alert letting user kwon they have to turn location permissions on
        }
    }
    //Check if the user autorized to use his location in the app
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
    //Get every time the user location and track it for if the user is moving around any place
    func startTrakingUserLocation() {
        
        mapView.showsUserLocation = true
        
        centerViewOnUserLocation()
        
        locationManager.startUpdatingLocation()
        previusLocation = getCenterLocation(for: mapView)
    }
    //Detect the user location and when the location is the maps do a zoom in the user location
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
    //Get the user position for later permit did a zoom in the mapsView
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    //Takes the addresses to the user wants to go
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
    //Set a rute from the user location to the destiny that the user wants to go
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
    //Set the maps before any route was added because if the user wants to search many routes
    func resetMapView(withNew directions: MKDirections) {
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map { $0.cancel() }
    }
}

extension HomeController: CLLocationManagerDelegate {
    //If your location changed with this method the map is going to go to the new location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let center = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionZoomMeters, longitudinalMeters: regionZoomMeters)
        
        mapView.setRegion(region, animated: true)
    }
    
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
            //Get the postal code and the street name from the center view
            let streetNumber = placemark.subThoroughfare ?? ""
            let streetName = placemark.thoroughfare ?? ""
            
            DispatchQueue.main.async {
                //Set the postal code and the street name in a label
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

