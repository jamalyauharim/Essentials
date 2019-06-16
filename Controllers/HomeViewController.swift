//
//  HomeViewController.swift
//  Essentials
//
//  Created by Jamal Yauhari on 6/16/19.
//  Copyright © 2019 Jamal Yauhari. All rights reserved.
//

import UIKit
import MapKit
import UserNotifications
import WatchConnectivity

class HomeViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, WCSessionDelegate {
    
    var mapView: MKMapView!
    var locationManager = CLLocationManager()
    var tableView = UITableView()
    var addButton = UIButton()
    var popMapButton = UIButton()
    let distanceSpan: CLLocationDistance = 1000
    let defaults = UserDefaults.standard
    var previousLocation: CLLocation?
    var essentialsWithKey: [String : String] = [:]
    var tableViewContent: [String?] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        // MapKit
        checkLocationService()
        
        // ViewController
        setUpTableView()
        setUpButton()
        
        // watchOS
        createSession()
        sendEssentials()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableViewContent = self.defaults.stringArray(forKey: "ArrayContent") ?? [String]()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        centerMapOnLocation()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: Button Views

    // setUpButton() : sets add button to HomeViewController.
    func setUpButton() {
        addButton = UIButton(frame: CGRect(x: 20, y: 650, width: Int(UIScreen.main.bounds.width - 40), height: 50))
        addButton.backgroundColor = DARK_GRAY_COLOR
        addButton.addTarget(self, action: #selector(addButtonAction), for: .touchUpInside)
        addButton.layer.cornerRadius = 10
        addButton.setTitle("Add Essential", for: .normal)
        addButton.setTitleColor(ORANGE_COLOR, for: .normal)
        addButtonAction(sender: addButton)
        self.view.addSubview(addButton)
    }
    
    @objc func addButtonAction(sender: UIButton) {
        setUpAlertAction()
    }
    
    // setUpMapButton() : sets clear button on top of mapView to trigger UIAlertController.
    func setUpMapButton() {
        popMapButton = UIButton(frame: CGRect(x: 20, y: 50, width: Int(UIScreen.main.bounds.width - 40), height: Int(UIScreen.main.bounds.height/3)))
        popMapButton.backgroundColor = .clear
        popMapButton.layer.cornerRadius = 10
        popMapButton.addTarget(self, action: #selector(popMapView), for: .touchUpInside)
        self.view.addSubview(popMapButton)
    }
    
    @objc func popMapView(sender: UIButton) {
        setUpOptionsAlert()
    }
    
    // MARK: Alert Views
    
    // setUpOptionsAlert() : sets UIAlertController to select and set Home location.
    func setUpOptionsAlert() {
        let optionsList = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        optionsList.addAction(UIAlertAction(title: "Set Home Location", style: .default, handler: { [unowned self] (action) in
            self.present(PopMapViewController(), animated: true, completion: nil)
        }))
        optionsList.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(optionsList, animated: true, completion: nil)
        
    }
    
    // setUpAlertAction() : sets UIAlertController to add essential to list.
    func setUpAlertAction() {
        let addPopUpBox = UIAlertController(title: "Add your essential", message: nil, preferredStyle: .alert)
        
        addPopUpBox.addTextField { (textField) in
            textField.autocapitalizationType = .sentences
        }
        
        addPopUpBox.addAction(UIAlertAction(title: "Add", style: .default, handler: { (action) in
            let textField = addPopUpBox.textFields![0] as UITextField
            
            if (textField.text == "" ) {
                
            } else {
                self.tableViewContent.append(textField.text)
                self.defaults.set(self.tableViewContent, forKey: "ArrayContent")
            }
        }))
        
        addPopUpBox.addAction(UIAlertAction(title: "Nevermind", style: .cancel, handler: nil))
        present(addPopUpBox, animated: true, completion: nil)
    }
    
    // MARK: TableView Configuration
    
    // setUpTableView() : sets tableView frame and appearence.
    func setUpTableView() {
        tableView = UITableView(frame: CGRect(x: 20, y: 350, width: Int(UIScreen.main.bounds.width - 40), height: Int(UIScreen.main.bounds.height/3)))
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(MenuItemTableViewCell.self, forCellReuseIdentifier: MenuItemTableViewCell.identifier)
        
        tableView.backgroundColor = DARK_GRAY_COLOR
        tableView.layer.cornerRadius = 10
        tableView.separatorColor = .clear
        self.view.addSubview(tableView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewContent.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MenuItemTableViewCell.identifier, for: indexPath) as! MenuItemTableViewCell
        
        cell.customTitleLabel.text = tableViewContent[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableViewContent.remove(at: indexPath.row)
            self.defaults.set(self.tableViewContent, forKey: "ArrayContent")
        }
    }
    
    //MARK: Map Configuration
    
    // setUpLocationManager() : sets location manager delegate to self and accuracy to best.
    func setUpLocationManager() {
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // checkLocationService() : sets location manager and checks authorization status.
    func checkLocationService() {
        if CLLocationManager.locationServicesEnabled() {
            setUpLocationManager()
            checkLocationAuthorization()
        }
    }
    
    // centerMapOnLocation() : sets the marker on mapView for users current location.
    func centerMapOnLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: distanceSpan, longitudinalMeters: distanceSpan)
            mapView?.setRegion(region, animated: true)
        }
    }
    
    // checkLocationAuthorization() : switch case to check for each of the authorization status.
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            break
        case .notDetermined:
            self.locationManager.requestAlwaysAuthorization()
            break
        case .restricted:
            break
        case .denied:
            break
        case .authorizedAlways:
            mapAppearence()
            centerMapOnLocation()
            self.locationManager.startMonitoringVisits()
            self.locationManager.distanceFilter = 100
            mapView.showsUserLocation = true
            centerMapOnLocation()
            previousLocation = getCenterLocation(for: mapView)
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
    // mapAppearence() : sets map view frame and appearence.
    func mapAppearence() {
        self.mapView = MKMapView(frame: CGRect(x: 20, y: 50, width: Int(UIScreen.main.bounds.width - 40), height: Int(UIScreen.main.bounds.height/3)))
        self.mapView?.layer.cornerRadius = 10
        self.view.addSubview(self.mapView!)
        setUpMapButton()
    }
    
    // MARK: User Tracking
    
    // getCenterLocation() :  transforms latitude and longitude to a CLLocation type to get current location.
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        // Trigger notification.
        NotificationDelegate().scheduleNotification()
    }
    
    // MARK: WatchOS connectivity
    
    func createSession() {
        if (WCSession.isSupported()) {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    func sendEssentials() {
        if (WCSession.default.isReachable) {
            
            let messageWithEssentialsArray = self.defaults.dictionaryRepresentation()
            WCSession.default.sendMessage(messageWithEssentialsArray, replyHandler: nil) { (error) in
                return
            }
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        return
    }
    
    #if os(iOS)
    public func sessionDidBecomeInactive(_ session: WCSession) { }
    public func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    #endif
    
}

// MARK: NotificationDelegate
class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    
    let center = UNUserNotificationCenter.current()
    var essentials: [String] = []
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge])
    }
    
    // retrieveEssentials() : retrieves list of essentials from NSUserDefaults.
    func retrieveEssentials() {
        for essential in HomeViewController().defaults.stringArray(forKey: "ArrayContent") ?? [String]() {
            essentials.append(essential)
        }
    }
    
    // scheduleNotification() : schedules a notification to trigger.
    func scheduleNotification() {
        retrieveEssentials()
        center.delegate = self
        let content = UNMutableNotificationContent()
        // Notification formating.
        content.title = "DONT FORGET..."
        
        for item in essentials {
            content.body += " • \(item)"
            (item.last != nil) ? content.body += "\n" : ()
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "TimerDone", content: content, trigger: trigger)
        center.add(request, withCompletionHandler: nil)
    }
}
