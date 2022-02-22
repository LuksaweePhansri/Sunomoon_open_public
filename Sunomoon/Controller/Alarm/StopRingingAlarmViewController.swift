//
//  StopRingingAlarmViewController.swift
//  Sunomoon
//
//  Created by Luksawee Phansri on 6/4/21.
//

import Foundation
import UIKit
import RealmSwift
import AVFoundation
import CoreMotion

class StopRingingAlarmViewController: UIViewController  {
    @IBOutlet weak var stopAlarmBtn: UIButton!
    @IBOutlet weak var snoozeAlarmBtn: UIButton!
    
    // variables to load data from Realm
    var date: Date = Date()
    let realm = try! Realm()
    var alarmDatas: Results<AlarmData>?
    var alarmDataModel = AlarmData()
    var selectedSound: String = "Default"
    var player: AVAudioPlayer!
    var hour: Int = 00
    var minute: Int = 00
    var numberAlarms: Int = 0
    var mission: String?
    var snoozeEnable: Bool = false
    var alarmIndex: Int = 0
    
    // variable to access coremotion
    let manager = CMMotionManager()
    let activityManager = CMMotionActivityManager()
    let pedometer: CMPedometer = CMPedometer()
    var isPedometerAvailable: Bool {
        return CMPedometer.isPedometerEventTrackingAvailable() && CMPedometer.isDistanceAvailable() && CMPedometer.isStepCountingAvailable()
    }
    
    // Use to not allow user to get the auto rotation
    override var shouldAutorotate: Bool {
        return false
    }
    
    override func viewDidLoad() {
        // make app to have light theme
        overrideUserInterfaceStyle = .light
        // lock to portrait
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setStopAlamBtnStyle(btn: stopAlarmBtn)
        print("StopRingingAlarmVC")
        print("date: \(date)")
        dateToHourMin(date: date)
        alarmDatas = alarmDataModel.loadAlarmDatas()
        numberAlarms = alarmDatas!.count
        for i in 0..<numberAlarms {
            if((alarmDatas![i].hour == hour) && (alarmDatas![i].minute == minute) && (alarmDatas![i].enabled) ){
                print("find ringing alarm")
                selectedSound = alarmDatas![i].alarmSound
                print("selectSound: \(selectedSound)")
                mission = alarmDatas![i].mission
                snoozeEnable = alarmDatas![i].snoozeEnabled
                alarmIndex = i
            }
        }
        
        if(!snoozeEnable){
            snoozeAlarmBtn.isEnabled = false
            snoozeAlarmBtn.isHidden = true
        }
        playAlarmSound(selectedSound: selectedSound)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Lock scene orientation
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    //MARK: - Pressed STOP btn
    //when user press stop app need to check sensor if the sensor is available will allow user to do mission if not it will jump to DailyAlarmInfoViewController
    @IBAction func pressedStopBtn(_ sender: Any) {
        print("pressed STOP btn")
        if(mission == "Off") {
            // disable alarm case no repeat
            alarmDataModel.disableAlarm(alarmDatas: alarmDatas, index: alarmIndex)
            AlarmService.instance.reSchedule()
            player.stop()
            SelectedScene.instance.goToDailyAlarmInfoVC()
        }
        else if(mission == "Squat"){
            if(manager.isDeviceMotionAvailable){
                SelectedScene.instance.goToPrepareUserBeforeDoAlarmMissionVC(date: date)
            }
            else {
                // disable alarm case no repeat
                alarmDataModel.disableAlarm(alarmDatas: alarmDatas, index: alarmIndex)
                AlarmService.instance.reSchedule()
                player.stop()
                SelectedScene.instance.goToDailyAlarmInfoVC()
            }
        }
        else if(mission == "Typing"){
            SelectedScene.instance.goToPrepareUserBeforeDoAlarmMissionVC(date: date)
        }
        else if(mission == "Shake"){
            if(manager.isAccelerometerAvailable){
                SelectedScene.instance.goToPrepareUserBeforeDoAlarmMissionVC(date: date)
            }
            else {
                // disable alarm case no repeat
                alarmDataModel.disableAlarm(alarmDatas: alarmDatas, index: alarmIndex)
                AlarmService.instance.reSchedule()
                player.stop()
                SelectedScene.instance.goToDailyAlarmInfoVC()
            }
        }
        else if(mission == "Memo"){
            SelectedScene.instance.goToPrepareUserBeforeDoAlarmMissionVC(date: date)
        }
        
        else if(mission == "Math"){
            SelectedScene.instance.goToPrepareUserBeforeDoAlarmMissionVC(date: date)
        }
        else {
            print("Mission is error")
            // disable alarm case no repeat
            alarmDataModel.disableAlarm(alarmDatas: alarmDatas, index: alarmIndex)
            AlarmService.instance.reSchedule()
            player.stop()
            SelectedScene.instance.goToDailyAlarmInfoVC()
        }
    }
    
    //MARK: - Press SNOOZE btn
    @IBAction func pressedSnoozeBtn(_ sender: Any) {
    }
    
    //MARK: - play sound
    func playAlarmSound(selectedSound: String) {
        let alarmSound = Bundle.main.url(forResource: selectedSound, withExtension: "mp3")
        // to make sound even though user mute
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
        player = try! AVAudioPlayer(contentsOf: alarmSound!)
        player.play()
        player.numberOfLoops = -1
    }
    
    //MARK: - other relate function
    func dateToHourMin(date: Date) {
        let calendar = Calendar.current
        let hr = calendar.component(.hour, from: date)
        let min = calendar.component(.minute, from: date)
        hour = hr
        minute = min
    }
    
    func setStopAlamBtnStyle(btn: UIButton) {
        // set label color
        btn.setTitleColor(UIColor.white, for: .normal)
        // set label font
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 28.0)
        // set background
        btn.backgroundColor = .red
        // set btn radius
        btn.layer.cornerRadius = 15
    }
}
