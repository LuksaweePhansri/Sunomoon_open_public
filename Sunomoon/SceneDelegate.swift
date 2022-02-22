//
//  SceneDelegate.swift
//  Sunomoon
//
//  Created by Luksawee Phansri on 1/15/21.
//

import UIKit
import FSCalendar

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    let scenceDelegate = UIApplication.shared.delegate as! AppDelegate
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        print("scene")
        if #available(iOS 13.0, *){
            guard let scene = (scene as? UIWindowScene) else { return }
            let window: UIWindow = UIWindow(frame: scene.coordinateSpace.bounds)
            window.windowScene = scene //Make sure to do this
            window.rootViewController = storyboard.instantiateViewController(withIdentifier: "TabBarController") as? TabBarController
            window.makeKeyAndVisible()
            scenceDelegate.window = window
        } else {
            scenceDelegate.window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "TabBarController") as? TabBarController
            scenceDelegate.window?.makeKeyAndVisible()
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
        print("sceneDidDisconnect")
        
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        // will use incase user did not press the notification
        print("sceneDidBecomeActive")
        AlarmService.instance.stopSound()
        var numberDeliveryNotification: Int = 0
        var date: Date = Date()
        var notifcation = UserNotificationsService()
        notifcation.userNotificationCenter.getDeliveredNotifications (completionHandler: { [self]deliveredNotifications -> () in
            numberDeliveryNotification = deliveredNotifications.count
            for notification in deliveredNotifications{
                if(numberDeliveryNotification > 0) {
                    // alarm notification
                    if(notification.request.content.categoryIdentifier == "alarm"){
                        print("Have notification")
                        date = notification.date
                        print(notification.date)
                        DispatchQueue.main.async {
                            SelectedScene.instance.goToStopRingingAlarmVC(date: date)
                        }
                    }
                }
            }
        })
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        // schedule alarm notification
        AlarmService.instance.scheduleAlarmNotification()
        print("sceneWillResignActive")
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        print("sceneWillEnterForeground")
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        // to make todayViwController as the default
        //SelectedScene.instance.goToTodayVC()
        print("sceneDidEnterBackground")
    }
}

