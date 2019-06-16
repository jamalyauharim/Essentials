//
//  CustomTabBarController.swift
//  Essentials
//
//  Created by Jamal Yauhari on 6/16/19.
//  Copyright © 2019 Jamal Yauhari. All rights reserved.
//

import Foundation
import UIKit

class CustomTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let firstView = HomeViewController()
        firstView.tabBarItem = UITabBarItem(tabBarSystemItem: .mostViewed, tag: 0)
        
        let secondView = SettingsViewController()
        secondView.tabBarItem = UITabBarItem(tabBarSystemItem: .more, tag: 1)
        
        viewControllers = [firstView, secondView]
        
        self.tabBar.isTranslucent = false
        self.tabBar.barTintColor = TAB_BAR_COLOR
        self.tabBar.unselectedItemTintColor = LIGHT_GRAY_COLOR
        self.tabBar.tintColor = ORANGE_COLOR
        
    }
}
