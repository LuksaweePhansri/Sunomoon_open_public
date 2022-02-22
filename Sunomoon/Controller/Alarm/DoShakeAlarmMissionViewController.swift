//
//  DoAlarmMissionViewController.swift
//  Sunomoon
//
//  Created by Luksawee Phansri on 6/10/21.
//

import Foundation
import UIKit
import RealmSwift
import CoreMotion

class DoShakeAlarmMissionViewController: UIViewController  {
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var remainMission: UILabel!
    
    // variable to access coremotion
    let manager = CMMotionManager()
    let activityManager = CMMotionActivityManager()
    let pedometer: CMPedometer = CMPedometer()
    var isPedometerAvailable: Bool {
        return CMPedometer.isPedometerEventTrackingAvailable() && CMPedometer.isDistanceAvailable() && CMPedometer.isStepCountingAvailable()
    }
    var x0: Double = 1
    var y0: Double = 1
    var z0: Double = 1
    var shakeTimer: Timer?
    
    // variables to load data from Realm
    var date: Date = Date()
    let realm = try! Realm()
    var alarmDatas: Results<AlarmData>?
    var alarmDataModel = AlarmData()
    var numberAlarms: Int = 0
    var hour: Int = 00
    var minute: Int = 00
    var missionNumber: Int?
    var missionLevel: String?
    var countMission: Int = 0
    
    // get sound and manage progreesBar
    var soundPlayer = SoundPlayer()
    var progressBarTimer: Timer?
    var secondsPassed: Float = 0
    var timeLimit:Float = 15
    
    var alarmIndex: Int = 0
    
    // Use to not allow user to get the auto rotation
    override var shouldAutorotate: Bool {
        print("DoShakeAlarmMissionViewController shouldAutorotate")
        return false
    }
    
    override func viewDidLoad() {
        // make app to have light theme
        overrideUserInterfaceStyle = .light
        // lock to portrait
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        super.viewDidLoad()
        print("DoShakeAlarmMissionVC viewDidLoad")
        dateToHourMin(date: date)
        alarmDatas = alarmDataModel.loadAlarmDatas()
        numberAlarms = alarmDatas!.count
        print("countMission: \(countMission)")
        for i in 0..<numberAlarms {
            if((alarmDatas![i].hour == hour) && (alarmDatas![i].minute == minute) && (alarmDatas![i].enabled) ){
                print("find ringing alarm")
                missionNumber = alarmDatas![i].missionNumber
                missionLevel = alarmDatas![i].missionLevel
                alarmIndex = i
            }
        }
        remainMission.text = "\(missionNumber ?? 5) times"
        progressBarTimer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(updateProgressBarTimer), userInfo: nil, repeats: true)
        countShake()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("DoShakeAlarmMissionVC viewWillApear")
        super.viewWillAppear(animated)
        // Lock scene orientation
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("DoShakeAlarmMissionVC viewWillDisappear")
        super.viewWillDisappear(animated)
    }
    
    // MARK: - upadate progressBar timer
    @objc func updateProgressBarTimer() {
        if(manager.isAccelerometerAvailable){
            print("updateProgressBarTimer")
            if(secondsPassed < timeLimit){
                secondsPassed += 0.25
                progressBar.progress = Float(timeLimit - secondsPassed) / Float(timeLimit)
            }
            else {
                progressBarTimer?.invalidate()
                shakeTimer?.invalidate()
                print("Time up")
                self.manager.startAccelerometerUpdates()
                SelectedScene.instance.goToStopRingingAlarmVC(date: date)
            }
        }
    }
    
    // MARK: - Shake
    func countShake() {
        // check accelerometer
        if(manager.isAccelerometerAvailable){
            manager.startAccelerometerUpdates()
            // specify the update time
            var sensorValue: Double = 0
            shakeTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [self] _ in
                if let data = self.manager.accelerometerData {
                    let x = data.acceleration.x
                    let y = data.acceleration.y
                    let z = data.acceleration.z
                    print(x)
                    print(y)
                    print(z)
                    switch missionLevel {
                    case "easy":
                        sensorValue = 1
                        if((abs(x) > sensorValue) || (abs(y) > sensorValue) || (abs(z) > sensorValue)){
                            countMission += 1
                            secondsPassed = 0
                            print("easy shake")
                            soundPlayer.playSound(selectedSound: "MissionComplete")
                        }
                    case "normal":
                        sensorValue = 3
                        if((abs(x) > sensorValue) || (abs(y) > sensorValue) || (abs(z) > sensorValue)){
                            countMission += 1
                            secondsPassed = 0
                            print("normal shake")
                            soundPlayer.playSound(selectedSound: "MissionComplete")
                        }
                    case "hard":
                        sensorValue = 5
                        if((abs(x) > sensorValue) || (abs(y) > sensorValue) || (abs(z) > sensorValue)){
                            countMission += 1
                            secondsPassed = 0
                            print("hard shake")
                            soundPlayer.playSound(selectedSound: "MissionComplete")
                        }
                    default:
                        countMission += 0
                    }
                    remainMission.text = "\(missionNumber! - countMission) times"
                    if(countMission >= missionNumber!) {
                        // go to DailyAlarmInfo
                        reScheduleAlarmAndGoToNextScene()
                    }
                }
            }
        }
        // To handle if the devide does not have the accelerometer
        else {
            print("do not find accelerometer")
            reScheduleAlarmAndGoToNextScene()
        }
    }
    
    // assign to next scence
    func reScheduleAlarmAndGoToNextScene() {
        // disable alarm case no repeat
        alarmDataModel.disableAlarm(alarmDatas: alarmDatas, index: alarmIndex)
        print("stop")
        progressBarTimer?.invalidate()
        // stop timer
        shakeTimer?.invalidate()
        // reset value
        countMission = 0
        // stop sensor to check shaking
        self.manager.stopAccelerometerUpdates()
        // reschedule notification
        AlarmService.instance.reSchedule()
        SelectedScene.instance.goToDailyAlarmInfoVC()
    }
    
    //MARK: - other relate func
    func dateToHourMin(date: Date) {
        let calendar = Calendar.current
        let hr = calendar.component(.hour, from: date)
        let min = calendar.component(.minute, from: date)
        hour = hr
        minute = min
    }
}
