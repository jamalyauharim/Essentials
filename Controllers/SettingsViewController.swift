//
//  SettingsViewController.swift
//  Essentials
//
//  Created by Jamal Yauhari on 6/16/19.
//  Copyright © 2019 Jamal Yauhari. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class SettingsViewController: UIViewController {
    
    static var settedHomeLocation = UILabel()
    var settedHomeLocationTitle = UILabel()
    static let settingsDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        setHomeAddressLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SettingsViewController.settedHomeLocation.text = SettingsViewController.settingsDefaults.string(forKey: "HomeAdress")
    }
    
    func setHomeAddressLabel() {
        
        settedHomeLocationTitle = UILabel(frame: CGRect(x: 5, y: 100, width: Int(UIScreen.main.bounds.width), height: 20))
        settedHomeLocationTitle.textColor = .white
        settedHomeLocationTitle.font = UIFont.boldSystemFont(ofSize: 24)
        settedHomeLocationTitle.text = "Your Home Address"
        SettingsViewController.settedHomeLocation = UILabel(frame: CGRect(x: 0, y: 130, width: Int(UIScreen.main.bounds.width), height: 50))
        SettingsViewController.settedHomeLocation.backgroundColor = DARK_GRAY_COLOR
        SettingsViewController.settedHomeLocation.textColor = .white
        SettingsViewController.settedHomeLocation.textAlignment = .center
        self.view.addSubview(SettingsViewController.settedHomeLocation)
        self.view.addSubview(settedHomeLocationTitle)
    }
}

