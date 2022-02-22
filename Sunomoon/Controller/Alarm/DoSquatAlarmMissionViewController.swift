//
//  DoSquatAlarmMissionViewController.swift
//  Sunomoon
//
//  Created by Luksawee Phansri on 6/19/21.
//

import Foundation
import UIKit
import RealmSwift
import CoreMotion


class DoSquatAlarmMissionViewController: UIViewController {
    let manager = CMMotionManager()
    @IBOutlet weak var squatLabel: UILabel!
    @IBOutlet weak var rightThumbBtn: UIButton!
    @IBOutlet weak var leftThumbBtn: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    
    // variables to load data from Realm
    var date: Date = Date()
    let realm = try! Realm()
    var alarmDatas: Results<AlarmData>?
    var alarmDataModel = AlarmData()
    var numberAlarms: Int = 0
    var hour: Int = 00
    var minute: Int = 00
    var missionNumber: Int = 5
    var countMission: Int = 0
    var alarmIndex: Int = 0
    
    // get sound and manage progreesBar
    var squatTimer: Timer?
    var progressBarTimer: Timer?
    var secondsPassed = 0
    var timeLimit = 30
    var soundPlayer = SoundPlayer()
    
    // Use to not allow user to get the auto rotation
    override var shouldAutorotate: Bool {
        print("shouldAutorotate")
        return true
    }
    
    override func viewDidLoad() {
        // make app to have light theme
        overrideUserInterfaceStyle = .light
        // lock to portrait
        AppUtility.lockOrientation(.landscapeRight, andRotateTo: .landscapeRight)
        super.viewDidLoad()
        dateToHourMin(date: date)
        alarmDatas = alarmDataModel.loadAlarmDatas()
        numberAlarms = alarmDatas!.count
        print("countMission: \(countMission)")
        for i in 0..<numberAlarms {
            if((alarmDatas![i].hour == hour) && (alarmDatas![i].minute == minute) && (alarmDatas![i].enabled) ){
                print("find ringing alarm")
                missionNumber = alarmDatas![i].missionNumber
                alarmIndex = i
            }
        }
        
        // add target when user hold rightThumbBtn
        rightThumbBtn.addTarget(self, action: #selector(rightThumbBtnDown), for: .touchDown)
        // add target when user release rightThumbBtn
        rightThumbBtn.addTarget(self, action: #selector(rightThumbBtnUp), for: [.touchUpInside, .touchUpOutside])
        
        // add target when user hold leftThumbBtn
        leftThumbBtn.addTarget(self, action: #selector(leftThumbBtnDown), for: .touchDown)
        // add target when user release leftThumbBtn
        leftThumbBtn.addTarget(self, action: #selector(leftThumbBtnUp), for: [.touchUpInside, .touchUpOutside])
        
        progressBarTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateProgressBarTimer), userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Lock scene orientation
        AppUtility.lockOrientation(.landscapeRight, andRotateTo: .landscapeRight)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Reset when view is being removed
        AppUtility.lockOrientation(.portrait)
    }
    
    @objc func rightThumbBtnDown(_ sender: UIButton){
        print("rightThumbBtnDown")
        if(leftThumbBtn.isTouchInside) {
            countSquat()
            squatTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countSquat), userInfo: nil, repeats: true)
        }
    }
    
    @objc func rightThumbBtnUp(_ sender: UIButton){
        print("rightThumbBtnUP")
        squatTimer?.invalidate()
    }
    
    @objc func leftThumbBtnDown(_ sender: UIButton){
        print("leftThumbBtnDown")
        if(rightThumbBtn.isTouchInside) {
            countSquat()
            squatTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countSquat), userInfo: nil, repeats: true)
        }
    }
    
    @objc func leftThumbBtnUp(_ sender: UIButton){
        print("leftThumbBtnUP")
        squatTimer?.invalidate()
    }
    
    //MARK: - ProgressBar timer
    @objc func updateProgressBarTimer() {
        if(secondsPassed < timeLimit){
            secondsPassed += 1
            progressBar.progress = Float(timeLimit - secondsPassed) / Float(timeLimit)
        }
        else {
            progressBarTimer?.invalidate()
            squatTimer?.invalidate()
            print("Time up")
            self.manager.stopDeviceMotionUpdates()
            SelectedScene.instance.goToStopRingingAlarmVC(date: date)
        }
    }
    
    //MARK:- Squat
    @objc func countSquat() {
        if manager.isDeviceMotionAvailable {
            manager.startDeviceMotionUpdates()
            if let data = manager.deviceMotion {
                var aX = Double(round(1000 * data.userAcceleration.x)/1000)
                var aZ = Double(round(1000 * data.userAcceleration.z)/1000)
                var aveXZ = (sqrt(pow(aX, 2) + pow(aZ, 2)))/2
                var roundAveXZ = Double(round(aveXZ * 1000) / 1000)
                print("roudAveXZ: \(roundAveXZ)")
                if(roundAveXZ > 0.125){
                    soundPlayer.playSound(selectedSound: "MissionComplete")
                    countMission += 1
                    print("coutMission: \(countMission)")
                    secondsPassed = 0
                }
                squatLabel.text = "Squat \(missionNumber - countMission) rounds"
                if(countMission >= missionNumber) {
                    self.manager.stopDeviceMotionUpdates()
                    reScheduleAlarmAndGoToNextScene()
                }
            }
        }
    }
    
    //MARK: - other relate func
    func dateToHourMin(date: Date) {
        let calendar = Calendar.current
        let hr = calendar.component(.hour, from: date)
        let min = calendar.component(.minute, from: date)
        print("hours = \(hr):\(min)")
        hour = hr
        minute = min
    }
    
    func reScheduleAlarmAndGoToNextScene() {
        print("stop")
        // disable alarm case no repeat
        alarmDataModel.disableAlarm(alarmDatas: alarmDatas, index: alarmIndex)
        squatTimer?.invalidate()
        progressBarTimer?.invalidate()
        // reset value
        countMission = 0
        // reschedule notification
        AlarmService.instance.reSchedule()
        SelectedScene.instance.goToDailyAlarmInfoVC()
    }
}
