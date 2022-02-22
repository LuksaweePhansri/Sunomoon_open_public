//
//  PrepareUserBeforeDoAlarmMissionViewController.swift
//  Sunomoon
//
//  Created by Luksawee Phansri on 6/19/21.
//

import Foundation
import UIKit
import RealmSwift

class PrepareUserBeforeDoAlarmMissionViewController: UIViewController {
    @IBOutlet weak var missionLabel: UILabel!
    @IBOutlet weak var missionPic: UIImageView!
    @IBOutlet weak var readyBtn: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    
    // variables to load data from Realm
    var date: Date = Date()
    let realm = try! Realm()
    var alarmDatas: Results<AlarmData>?
    var alarmDataModel = AlarmData()
    var hour: Int = 00
    var minute: Int = 00
    var numberAlarms: Int = 0
    var mission: String = "Shake"
    var missionNumber: Int?
    var picName: String = "shake"
    var alarmIndex: Int = 0
    
    // manage progreesBar
    var progressBarTimer: Timer?
    var secondsPassed = 0
    var timeLimit = 45
    
    // Use to not allow user to get the auto rotation
    override var shouldAutorotate: Bool {
        return false
    }
    
    override func viewDidLoad() {
        print("PrepareUsereBeforeDoAlarmVC")
        // make app to have light theme
        overrideUserInterfaceStyle = .light
        // Lock scene orientation
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        super.viewDidLoad()
        print("date: \(date)")
        dateToHourMin(date: date)
        alarmDatas = alarmDataModel.loadAlarmDatas()
        numberAlarms = alarmDatas!.count
        for i in 0..<numberAlarms {
            if((alarmDatas![i].hour == hour) && (alarmDatas![i].minute == minute) && (alarmDatas![i].enabled) ){
                print("find ringing alarm")
                mission = alarmDatas![i].mission
                missionNumber = alarmDatas![i].missionNumber
                alarmIndex = i
            }
        }
        
        setBackgroundComponents(mission: mission)
        progressBarTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateProgressBarTimer), userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Lock scene orientation
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
    }
    
    //MARK: - progressBar timer
    @objc func updateProgressBarTimer() {
        if(secondsPassed < timeLimit){
            secondsPassed += 1
            progressBar.progress = Float(timeLimit - secondsPassed) / Float(timeLimit)
        }
        else {
            print("Time up")
            progressBarTimer?.invalidate()
            SelectedScene.instance.goToStopRingingAlarmVC(date: date)
        }
    }
    
    // MARK: - user press READY btn
    @IBAction func pressedReadyBtn(_ sender: Any) {
        print("pressed ready btn")
        secondsPassed = 0
        progressBarTimer?.invalidate()
        if(mission == "Memo") {
            SelectedScene.instance.goToDoMemoAlarmMissionVC(date: date)
        }
        else if(mission == "Squat") {
            SelectedScene.instance.goToDoSquatAlarmMissionVC(date: date)
        }
        else if(mission == "Math") {
            SelectedScene.instance.goToDoMathAlarmMissionVC(date: date)
        }
        else if(mission == "Shake") {
            SelectedScene.instance.goToDoShakeAlarmMissionVC(date: date)
        }
        else if(mission == "Typing"){
            SelectedScene.instance.goToDoTypingAlarmMissionVC(date: date)
        }
        // support to not get in this case
        else {
            // disable alarm case no repeat
            alarmDataModel.disableAlarm(alarmDatas: alarmDatas, index: alarmIndex)
            SelectedScene.instance.goToDailyAlarmInfoVC()
            SelectedScene.instance.goToDailyAlarmInfoVC()
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
    
    //MARK: - set background components
    func setBackgroundComponents(mission: String){
        // set readyBtn
        setReadyBtnStyle(btn: readyBtn)
        // make mission to lowercase
        picName = mission.lowercased()
        print(picName)
        missionPic.image = UIImage(named: picName)
        switch mission {
        case "Squat":
            if(missionNumber == 1){
                missionLabel.text = ("\(mission) 1 round")
            }
            else {
                missionLabel.text = ("\(mission) \(missionNumber ?? 5) rounds")
            }
        case "Typing":
            if(missionNumber == 1){
                missionLabel.text = ("Type 1 sentence")
            }
            else {
                missionLabel.text = ("Type \(missionNumber ?? 1) sentences")
            }
        case "Shake":
            if(missionNumber == 1){
                missionLabel.text = ("\(mission) 1 time")
            }
            else {
                missionLabel.text = ("\(mission) \(missionNumber ?? 5) times")
            }
        case "Memo":
            if(missionNumber == 1){
                missionLabel.text = ("Play memo 1 game")
            }
            else {
                missionLabel.text = ("Play memo \(missionNumber ?? 3) games")
            }
            missionLabel.font = UIFont.boldSystemFont(ofSize: 32.0)
        case "Math":
            if(missionNumber == 1){
                missionLabel.text = ("Do the math 1 game")
            }
            else {
                missionLabel.text = ("Do the math \(missionNumber ?? 3) games")
            }
            missionLabel.font = UIFont.boldSystemFont(ofSize: 32.0)
        default:
            print("Default")
        }
    }
    
    func setReadyBtnStyle(btn: UIButton) {
        // set label font
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 28.0)
        // set btn radius
        btn.layer.cornerRadius = 15
    }
}
