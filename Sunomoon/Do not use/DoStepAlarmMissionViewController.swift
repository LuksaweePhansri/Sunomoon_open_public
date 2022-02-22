////
////  DoAlarmMissionViewController.swift
////  Sunomoon
////
////  Created by Luksawee Phansri on 6/10/21.
////
//
//import Foundation
//import UIKit
//import RealmSwift
//import CoreMotion
//
//class DoStepAlarmMissionViewController: UIViewController  {
//    @IBOutlet weak var missionLabel: UILabel!
//    @IBOutlet weak var remainMission: UILabel!
//    @IBOutlet weak var pic: UIImageView!
//    @IBOutlet var progressBar: UIView!
//    let manager = CMMotionManager()
//    let activityManager = CMMotionActivityManager()
//    let pedometer: CMPedometer = CMPedometer()
//    var isPedometerAvailable: Bool {
//        return CMPedometer.isPedometerEventTrackingAvailable() && CMPedometer.isDistanceAvailable() && CMPedometer.isStepCountingAvailable()
//    }
//    var date: Date = Date()
//    let realm = try! Realm()
//    var alarmDatas: Results<AlarmData>?
//    var alarmDataModel = AlarmData()
//    var numberAlarms: Int = 0
//    var hour: Int = 00
//    var minute: Int = 00
//    var mission: String = "Shake"
//    var missionNumber: Int?
//    var missionLevel: String?
//    var countMission: Int = 0
//    var picName: String = "shake"
//    var index: Int = 0
//    var x0: Double = 1
//    var y0: Double = 1
//    var z0: Double = 1
//    // Use to not allow user to get the auto rotation
//    override var shouldAutorotate: Bool {
//        print("shouldAutorotate")
//        return false
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        dateToHourMin(date: date)
//        alarmDatas = alarmDataModel.loadAlarmDatas()
//        numberAlarms = alarmDatas!.count
//        print("countMission: \(countMission)")
//        for i in 0..<numberAlarms {
//            if((alarmDatas![i].hour == hour) && (alarmDatas![i].minute == minute) && (alarmDatas![i].enabled) ){
//                print("find ringing alarm")
//                mission = alarmDatas![i].mission
//                missionNumber = alarmDatas![i].missionNumber
//                missionLevel = alarmDatas![i].missionLevel
//            }
//        }
//        setBackgroundComponents(mission: mission)
//        setStopAlarmMission(mission: mission)
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        // Lock scene orientation
//        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
//    }
//
//
//
//
//    // MARK: - set stop alarm
//    func setStopAlarmMission(mission : String){
//        switch mission {
//        case "Shake":
//            countShake()
//        case "Step":
//            print("Step")
//            countStep()
//        default:
//            print("Default")
//        }
//    }
//
//    // MARK: -Squat
//    func countSquat() {
//        // check accelerometer
//        if(manager.isAccelerometerAvailable){
//            manager.startAccelerometerUpdates()
//            while(countMission < missionNumber ?? 5){
//                if let data = self.manager.accelerometerData {
//                    let x = data.acceleration.x
//                    let z = data.acceleration.z
//                    if(x/x0 < 0){
//                        print("Squat")
//                        countMission += 1
//                    }
//                }
//            }
//            manager.stopAccelerometerUpdates()
//        }
//    }
//
//
//
//    // MARK: - Step
//    func countStep() {
//        // check accelerometer
//        if(manager.isAccelerometerAvailable){
//            manager.startAccelerometerUpdates()
//            // specify the update time
//            var sensorXValue: Double = 0.1
//            var sensorYValue: Double = 0.5
//            var sensorZValue: Double = 1.5
//            var timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [self] _ in
//                if let data = self.manager.accelerometerData {
//                    let x = data.acceleration.x
//                    let y = data.acceleration.y
//                    let z = data.acceleration.z
//
//                    if((x > sensorXValue) || (abs(y) > sensorYValue) || (abs(z) > sensorZValue)){
//                        print("walk")
//                        countMission += 1
//                    }
//
//                    remainMission.text = "\(missionNumber! - countMission) steps"
//                    if(countMission >= missionNumber!) {
//                        // stop timer
//                        timer.invalidate()
//                        // stop sensor to check shaking
//                        self.manager.stopAccelerometerUpdates()
//                        reScheduleAlarmAndGoToNextScene()
//                    }
//                }
//            }
//        }
//        // To handle if the devide does not have the accelerometer
//        else {
//            //reScheduleAlarmAndGoToNextScene()
//            print("do not find accelerometer")
//        }
//    }
//
//    // MARK: - Shake
//    func countShake() {
//        // check accelerometer
//        if(manager.isAccelerometerAvailable){
//            manager.startAccelerometerUpdates()
//            // specify the update time
//            var sensorValue: Double = 0
//            var timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [self] _ in
//                if let data = self.manager.accelerometerData {
//                    let x = data.acceleration.x
//                    let y = data.acceleration.y
//                    let z = data.acceleration.z
//                    print(x)
//                    print(y)
//                    print(z)
//                    switch missionLevel {
//                    case "easy":
//                        sensorValue = 1
//                        if((abs(x) > sensorValue) || (abs(y) > sensorValue) || (abs(z) > sensorValue)){
//                            countMission += 1
//                        }
//                    case "normal":
//                        sensorValue = 3
//                        if((abs(x) > sensorValue) || (abs(y) > sensorValue) || (abs(z) > sensorValue)){
//                            countMission += 1
//                        }
//                    case "hard":
//                        sensorValue = 5
//                        if((abs(x) > sensorValue) || (abs(y) > sensorValue) || (abs(z) > sensorValue)){
//                            countMission += 1
//                        }
//                    default:
//                        countMission += 0
//                    }
//                    remainMission.text = "\(missionNumber! - countMission) times"
//                    if(countMission >= missionNumber!) {
//                        // stop timer
//                        timer.invalidate()
//                        // stop sensor to check shaking
//                        self.manager.stopAccelerometerUpdates()
//                        // go to DailyAlarmInfo
//                        reScheduleAlarmAndGoToNextScene()
//                    }
//                }
//            }
//        }
//        // To handle if the devide does not have the accelerometer
//        else {
//            //reScheduleAlarmAndGoToNextScene()
//            print("do not find accelerometer")
//        }
//    }
//    //MARK: - set background components
//    func setBackgroundComponents(mission: String){
//        missionLabel.text = mission
//        picName = mission.lowercased()
//        pic.image = UIImage(named: picName)
//        switch mission {
//        case "Shake":
//            remainMission.text = "\(missionNumber ?? 5) times"
//        case "Step":
//            remainMission.text = "\(missionNumber ?? 15) steps"
//
//
//        default:
//            print("Default")
//        }
//    }
//    //MARK: - other relate func
//    func dateToHourMin(date: Date) {
//        let calendar = Calendar.current
//        let hr = calendar.component(.hour, from: date)
//        let min = calendar.component(.minute, from: date)
//        print("hours = \(hr):\(min)")
//        hour = hr
//        minute = min
//    }
//
//    func reScheduleAlarmAndGoToNextScene() {
//        print("stop")
//        // reset value
//        countMission = 0
//        // reschedule notification
//        AlarmService.instance.reSchedule()
//        SelectedScene.instance.goToDailyAlarmInfoVC()
//    }
//}
