//
//  PopMapViewController.swift
//  Essentials
//
//  Created by Jamal Yauhari on 6/16/19.
//  Copyright © 2019 Jamal Yauhari. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

class PopMapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var mapView: MKMapView!
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 1000
    static var longitudOfLocation: Double?
    static var latitudeOfLocation: Double?
    var previousLocation: CLLocation?
    var addressLabel = UILabel()
    var backButtonFrame = UIButton()
    var setLocationButton = UIButton()
    var pinPointImage = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        checkLocationService()
    }
    
    func setUpView() {
        mapAppearence()
        backButton()
        setUpLabel()
        setLocation()
        setPinPoint()
    }
    
    func setPinPoint() {
        pinPointImage = UIImageView(frame: CGRect(x: (Int(UIScreen.main.bounds.width) - 20)/2, y: (Int(UIScreen.main.bounds.height) - 80) / 2, width: 20, height: 20))
        pinPointImage.image = UIImage(named: "x-icon")
        self.view.addSubview(pinPointImage)
    }
    
    func setLocation() {
        setLocationButton = UIButton(frame: CGRect(x: Int(UIScreen.main.bounds.width) - 50, y: 50, width: 30, height: 30))
        setLocationButton.setImage(UIImage(named: "setButton-image"), for: .normal)
        setLocationButton.addTarget(self, action: #selector(setLocationAction), for: .touchUpInside)
        self.view.addSubview(setLocationButton)
    }
    
    @objc func setLocationAction(sender: UIButton) {
        SettingsViewController.settingsDefaults.set(self.addressLabel.text, forKey: "HomeAdress")
        self.dismiss(animated: true, completion: nil)
    }
    
    func setUpLabel() {
        self.addressLabel = UILabel(frame: CGRect(x: 0, y: Int(UIScreen.main.bounds.height) - 100, width: Int(UIScreen.main.bounds.width), height: 100))
        self.addressLabel.backgroundColor = DARK_GRAY_COLOR
        self.addressLabel.textColor = .white
        self.addressLabel.textAlignment = .center
        self.view.addSubview(self.addressLabel)
    }
    
    func backButton() {
        backButtonFrame = UIButton(frame: CGRect(x: 20, y: 50, width: 30, height: 30))
        backButtonFrame.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        backButtonFrame.setImage(UIImage(named: "goBack-image"), for: .normal)
        backButtonAction(sender: backButtonFrame)
        self.view.addSubview(backButtonFrame)
    }
    
    @objc func backButtonAction(sender: UIButton) {
        if (self.addressLabel.text == nil) {
            self.addressLabel.text = SettingsViewController.settingsDefaults.string(forKey: "HomeAdress")
        }
        self.dismiss(animated: true, completion: nil )
    }
    
    func setUpLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func checkLocationService() {
        if CLLocationManager.locationServicesEnabled() {
            setUpLocationManager()
            checkLocationAuthorization()
        }
    }
    
    func mapAppearence() {
        self.mapView = MKMapView(frame: CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.width), height: Int(UIScreen.main.bounds.height) - 100))
        mapView.delegate = self
        self.view.addSubview(self.mapView!)
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            break
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        case .restricted:
            break
        case .denied:
            break
        case .authorizedAlways:
            centerViewOnUserLocation()
            mapView.showsUserLocation = true
            locationManager.startUpdatingLocation()
            previousLocation = getCenterLocation(for: mapView)
            break
        }
    }
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        let geoCoder = CLGeocoder()
        
        guard let previousLocation = self.previousLocation else { return }
        
        guard center.distance(from: previousLocation) > 10 else { return }
        self.previousLocation = center
        
        geoCoder.reverseGeocodeLocation(center) { (placeMarks, error) in
            
            if let _ = error { return }
            guard let placeMark = placeMarks?.first else { return }
            
            let streetNumber = placeMark.subThoroughfare ?? ""
            let streetName = placeMark.thoroughfare ?? ""
            let cityName = placeMark.locality ?? ""
            let stateName = placeMark.administrativeArea ?? ""
            let zipCode = placeMark.postalCode ?? ""
            PopMapViewController.longitudOfLocation = placeMark.location?.coordinate.longitude
            PopMapViewController.latitudeOfLocation = placeMark.location?.coordinate.latitude
            
            
            DispatchQueue.main.async {
                self.addressLabel.text = "\(streetNumber) " + "\(streetName)" + ", " + "\(cityName)" + ", " + "\(stateName)" + " \(zipCode)"
            }
        }
    }
}
