//
//  TabBarController.swift
//  Sunomoon
//
//  Created by Luksawee Phansri on 1/20/21.
//  Class to manage all the TabBar, and NavBar

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    override func viewDidLoad() {
        overrideUserInterfaceStyle = .light
        super.viewDidLoad()
        // tell our UITabBarController subclass to handle its own delegate methods
        self.delegate = self
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if (item.title == "Sleep") {
            UITabBar.appearance().isTranslucent = false
            tabBar.barTintColor = UIColor(named: "skyColor")
            //tabBar.barTintColor = UIColor(named: "nightColor")
            //tabBar.tintColor = UIColor(named: "AccentColor")
        } else if(item.title == "Alarm") {
            UITabBar.appearance().isTranslucent = false
            tabBar.barTintColor = UIColor.white
            //tabBar.tintColor = UIColor(named: "AccentColor")
            //tabBar.barTintColor = UIColor(named: "lightGrey")
        } else if(item.title == "Calendar") {
            UITabBar.appearance().isTranslucent = false
            //tabBar.tintColor = UIColor(named: "workBlue")
            //tabBar.barTintColor = UIColor(named: "lightGrey")
        } else {
            UITabBar.appearance().isTranslucent = false
            tabBar.barTintColor = nil
            //tabBar.tintColor = UIColor(named: "AccentColor")
        }
    }
    

    
    
}
