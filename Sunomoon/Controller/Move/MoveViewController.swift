//
//  MoveViewController.swift
//  Sunomoon
//
//  Created by Luksawee Phansri on 1/27/21.
//

import Foundation
import UIKit
import CoreMotion
import CoreLocation

class MoveViewController: UIViewController, CLLocationManagerDelegate  {
    let manager = CMMotionManager()
    let activityManager = CMMotionActivityManager()
    let pedometer: CMPedometer = CMPedometer()
    var step: Int?
    var isPedometerAvailable: Bool {
        return CMPedometer.isPedometerEventTrackingAvailable() && CMPedometer.isDistanceAvailable() && CMPedometer.isStepCountingAvailable()
    }
    let locationManager = CLLocationManager()
    
    var index: Int = 0
    var temp: Int = 0
    
    var totolStep: Int = 0
    @IBOutlet weak var stepLabel: UILabel!
    var status: String = "Test"
    var currentLocation: CLLocation!
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        print(".portrait")
       return .portrait
    }
    
    override var shouldAutorotate: Bool {
        print("shouldAutorotate")
        return false
    }
    
    override public var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
      return .portrait
    }
    


    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()

        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        let value = UIInterfaceOrientation.portrait.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")

//            if(CMMotionActivityManager.isActivityAvailable()){
//                activityManager.startActivityUpdates(to: OperationQueue.main) { (data) in
//                    DispatchQueue.main.async { [self] in
//                        if let activity = data {
//                            if (activity.running == true) {
//                                print("running")
//                                status = "running"
//                            }
//                            if (activity.walking == true) {
//                                print("walking")
//                                status = "walking"
//                            }
//                            if (activity.stationary == true) {
//                                print("stationary")
//                                status = "stationary"
//                            }
//                            if (activity.unknown == true) {
//                                print("unknown")
//                                status = "unknown"
//                            }
//                            if (activity.automotive == true) {
//                                print("automotive")
//                                status = "automotive"
//                            }
//                            if (activity.cycling == true) {
//                                print("cycling")
//                                status = "cycling"
//                            }
//                            stepLabel.text = status
//                        }
//                    }
//                }
//            }
    }
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
//        //print("locations = \(locValue.latitude) \(locValue.longitude)")
//        var firstLocation: CLLocation! = locations.first
//        print("first locations = \(firstLocation.coordinate.latitude) \(firstLocation.coordinate.longitude)")
//        var lastLocation: CLLocation! = locations.last
//        print("last locations = \(lastLocation.coordinate.latitude) \(lastLocation.coordinate.longitude)")
//    }
    override func viewWillAppear(_ animated: Bool) {
       super.viewWillAppear(animated)
       
       AppUtility.lockOrientation(.portrait)
        let value = UIInterfaceOrientation.portrait.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
       // Or to rotate and lock
       // AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
       
   }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Don't forget to reset when view is being removed
        AppUtility.lockOrientation(.all)
    }
}



