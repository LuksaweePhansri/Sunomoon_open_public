//
//  SelectedScene.swift
//  Sunomoon
//
//  Created by Luksawee Phansri on 6/10/21.
//  USe to set the seected scene

import Foundation
import UIKit

class SelectedScene {
    static let instance = SelectedScene()
    let scenceDelegate = UIApplication.shared.delegate as! AppDelegate
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    func setScene(conversationVC: UIViewController){
        if #available(iOS 13.0, *){
            if let scene = UIApplication.shared.connectedScenes.first{
                guard let windowScene = (scene as? UIWindowScene) else { return }
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
    
    func goToTodayVC() {
        if  let conversationVC = storyboard.instantiateViewController(withIdentifier: "TabBarController") as? TabBarController {
            setScene(conversationVC: conversationVC)
        }
    }
    
    func goToStopRingingAlarmVC(date: Date) {
        if  let conversationVC = storyboard.instantiateViewController(withIdentifier: "StopRingingAlarmViewController") as? StopRingingAlarmViewController {
            conversationVC.date = date
            setScene(conversationVC: conversationVC)
        }
    }
    
    func goToPrepareUserBeforeDoAlarmMissionVC(date: Date) {
        if  let conversationVC = storyboard.instantiateViewController(withIdentifier: "PrepareUserBeforeDoAlarmMissionViewController") as? PrepareUserBeforeDoAlarmMissionViewController {
            conversationVC.date = date
            setScene(conversationVC: conversationVC)
        }
    }
    
    func goToDoMemoAlarmMissionVC(date: Date){
        if  let conversationVC = storyboard.instantiateViewController(withIdentifier: "DoMemoAlarmMissionViewController") as? DoMemoAlarmMissionViewController {
            conversationVC.date = date
            setScene(conversationVC: conversationVC)
        }
    }
    
    func goToDoSquatAlarmMissionVC(date: Date){
        if  let conversationVC = storyboard.instantiateViewController(withIdentifier: "DoSquatAlarmMissionViewController") as? DoSquatAlarmMissionViewController {
            conversationVC.date = date
            setScene(conversationVC: conversationVC)
        }
    }
    
    func goToDoMathAlarmMissionVC(date: Date){
        if  let conversationVC = storyboard.instantiateViewController(withIdentifier: "DoMathAlarmMissionViewController") as? DoMathAlarmMissionViewController {
            conversationVC.date = date
            setScene(conversationVC: conversationVC)
        }
    }
    
    func goToDoShakeAlarmMissionVC(date: Date){
        if  let conversationVC = storyboard.instantiateViewController(withIdentifier: "DoShakeAlarmMissionViewController") as? DoShakeAlarmMissionViewController {
            conversationVC.date = date
            setScene(conversationVC: conversationVC)
        }
    }
    
    func goToDoTypingAlarmMissionVC(date: Date){
        if  let conversationVC = storyboard.instantiateViewController(withIdentifier: "DoTypingAlarmMissionViewController") as? DoTypingAlarmMissionViewController {
            conversationVC.date = date
            setScene(conversationVC: conversationVC)
        }
    }
    
    func goToDailyAlarmInfoVC() {
        if  let conversationVC = storyboard.instantiateViewController(withIdentifier: "DailyAlarmInfoViewController") as? DailyAlarmInfoViewController {
            setScene(conversationVC: conversationVC)
        }
    }
    

    




    
}
