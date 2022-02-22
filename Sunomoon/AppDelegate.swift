//
//  AppDelegate.swift
//  Sunomoon
//
//  Created by Luksawee Phansri on 1/15/21.
//

import UIKit
import RealmSwift
import AudioToolbox
import AVFoundation

//@main
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, AVAudioPlayerDelegate {
    var window: UIWindow?
    private static var singletonAccess: AppDelegate?
    
    // set orientations you want to be allowed in this property by default
    var orientationLock = UIInterfaceOrientationMask.all
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("application")
        // set the navigatioBar to not have the line
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        // to make the lunch screen sleep 1 s.
        try! FileManager.default.removeItem(atPath: NSHomeDirectory()+"/Library/SplashBoard")
        do {
            sleep(1)
        }
        
        // to print the realm location
        print(Realm.Configuration.defaultConfiguration.fileURL)
        //ctr + shift + G
        
        //test add data
        //        let data = AlarmData()
        //        data.date = Date()
        
        do {
            _ = try Realm()
            //            try realm.write {
            //                realm.add(data)
            //            }
        } catch {
            print("Error initialisting new reals, \(error)")
        }
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        print("applicationWillResignActive")
//        AlarmService.instance.scheduleAlarmNotification()
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        print("connectingSceneSession: UISceneSession")
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        print("didDiscardSceneSessions sceneSessions")
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // Set orientation to show
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientationLock
    }
}



