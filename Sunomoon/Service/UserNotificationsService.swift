//
//  UserNotificationsService.swift
//  Sunomoon
//
//  Created by Luksawee Phansri on 5/29/21.
//

import Foundation
import UIKit
import UserNotifications

class UserNotificationsService: NSObject {
    // instance that will use in other class
    static let instance = UserNotificationsService()
    let userNotificationCenter = UNUserNotificationCenter.current()
    
    // get authourize from user to make notification
    func alarmAuthorizeNotification() {
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        userNotificationCenter.requestAuthorization(options: options) { [self] isAuthorized, error in
            debugPrint(error ?? "No error in authorizing notification")
            guard isAuthorized else {
                print("User did not authorize notifications")
                return
            }
            userNotificationCenter.delegate = self
        }
    }
}

extension UserNotificationsService: UNUserNotificationCenterDelegate {
    // user click at the notification
    // use to access the screen to stopRingingAlarmViewController
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        let categoryIdentifier = response.notification.request.content.categoryIdentifier
        //print("user Info : \(userInfo)")
        //print("categoryIdentifier: \(categoryIdentifier)")
        var date: Date = Date()
        print("user clicked notification")
        userNotificationCenter.getDeliveredNotifications (completionHandler: {deliveredNotifications -> () in
            //print("\(deliveredNotifications.count) Delivered notifications-------")
            for notification in deliveredNotifications{
                //                print(notification.request.identifier)
                //print(notification.request.identifier)
                //print(response.actionIdentifier)
                date = notification.date
                
            }
        })
        dateToHourMin(date: date)
        
        // alarm notification
        if(categoryIdentifier == "alarm"){
            //SelectedScene.instance.goToStopRingingAlarmVC()
            let scenceDelegate = UIApplication.shared.delegate as! AppDelegate
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if  let conversationVC = storyboard.instantiateViewController(withIdentifier: "StopRingingAlarmViewController") as? StopRingingAlarmViewController {
                conversationVC.date = date
                if #available(iOS 13.0, *){
                    if let scene = UIApplication.shared.connectedScenes.first{
                        guard let windowScene = (scene as? UIWindowScene) else { return }
                        print(">>> windowScene: \(windowScene)")
                        let window: UIWindow = UIWindow(frame: windowScene.coordinateSpace.bounds)
                        window.windowScene = windowScene //Make sure to do this
                        window.rootViewController = conversationVC
                        window.makeKeyAndVisible()
                        scenceDelegate.window = window
                    }
                }
                else {
                    scenceDelegate.window?.rootViewController = conversationVC
                    scenceDelegate.window?.makeKeyAndVisible()
                }
            }
        }
        completionHandler()
        
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("willPresent")
        //SelectedScene.instance.goToStopRingingAlarmVC()
        let scenceDelegate = UIApplication.shared.delegate as! AppDelegate
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if  let conversationVC = storyboard.instantiateViewController(withIdentifier: "StopRingingAlarmViewController") as? StopRingingAlarmViewController {
            if #available(iOS 13.0, *){
                if let scene = UIApplication.shared.connectedScenes.first{
                    guard let windowScene = (scene as? UIWindowScene) else { return }
                    print(">>> windowScene: \(windowScene)")
                    let window: UIWindow = UIWindow(frame: windowScene.coordinateSpace.bounds)
                    window.windowScene = windowScene //Make sure to do this
                    window.rootViewController = conversationVC
                    window.makeKeyAndVisible()
                    scenceDelegate.window = window
                }
            }
            else {
                scenceDelegate.window?.rootViewController = conversationVC
                scenceDelegate.window?.makeKeyAndVisible()
            }
        }
    }
    
    func dateToHourMin(date: Date) {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        let hr = calendar.component(.hour, from: date)
        let min = calendar.component(.minute, from: date)
        let second = calendar.component(.second, from: date)
        print("Time now: \(hr):\(min):\(second)")
    }
}

