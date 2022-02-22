//
//  ViewController.swift
//  Sunomoon
//
//  Created by Luksawee Phansri on 1/15/21.
//

import UIKit
import CoreLocation
import AVFoundation
import Contacts


class TodayViewController: UIViewController  {
    var player: AVAudioPlayer!
    var selectedSound: String = "Default"
    var alarmTime: Bool = false
    
    @IBOutlet weak var pressedBtn: UIButton!
    let locationManager = CLLocationManager()
    let contactManager = CNContactStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("TodayViewController")
        // Do any additional setup after loading the view.
        // ask user to allow the app to access current location
        locationManager.requestWhenInUseAuthorization()
        // ask user to allow the app to access calendar
        CalendarData.instance.requestAccessToCalendar()
        requestAccessToContact()
    }
    
    // func to create another VC after pressing pressedBtn
    @IBAction func PressedMeBotton(_ sender: Any) {
        let vc = TodayViewController()
        vc.view.backgroundColor = .red
        navigationController?.pushViewController(vc, animated: true)
        // change NavBar color
        //vc.navigationController?.navigationBar.barTintColor = .red

    }
    
    func requestAccessToContact(){
        contactManager.requestAccess(for: .contacts) { isAuthorized, error in
            debugPrint(error ?? "No error in authorizing access event")
            guard isAuthorized else {
                print("User did not authorzeed to access event")
                return
            }
        }
    }
}

