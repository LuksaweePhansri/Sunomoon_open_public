//
//  DoMemoAlarmMissionViewController.swift
//  Sunomoon
//
//  Created by Luksawee Phansri on 6/29/21.
//

import Foundation
import UIKit
import RealmSwift
import AVFoundation

class DoMemoAlarmMissionViewController: UIViewController{
    @IBOutlet weak var missionLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var rememberTimeLabel: UILabel!
    @IBOutlet weak var gameStatusLabel: UILabel!
    @IBOutlet var arrayTotalBtn: [UIButton]!
    @IBOutlet weak var stackView1: UIStackView!
    @IBOutlet weak var stackView2: UIStackView!
    @IBOutlet weak var stackView3: UIStackView!
    @IBOutlet weak var stackView4: UIStackView!
    @IBOutlet weak var stackView5: UIStackView!
    
    // variables to load data from Realm
    var date: Date = Date()
    let realm = try! Realm()
    var alarmDatas: Results<AlarmData>?
    var alarmDataModel = AlarmData()
    var numberAlarms: Int = 0
    var hour: Int = 00
    var minute: Int = 00
    var missionNumber: Int = 3
    var missionLevel: String = "easy"
    var countMission: Int = 0
    var isUserSelectedRightTile: Bool = false
    var alarmIndex: Int = 0
    
    // get sound and manage progreesBar
    var soundPlayer = SoundPlayer()
    var progressBarTimer: Timer?
    var secondsPassed = 0
    var timeLimit = 15
    // rememberTimeeasy, normall, hard = 4, 5, 6
    var rememberTime = 4
    var showPickedTileTime = 2
    var rememberTimePassed = 0
    
    // manage title
    var clickedIndex: Int = 0
    var numRightTiles: Int = 0
    var totalTile: Int = 25
    // number of targetRightTiles: easy, normall, hard = 3, 5, 7
    var targetRightTiles: Int = 0
    var rightTilesSet: [Int] = [0, 1, 2, 3, 4, 5, 6]
    var totalTileInSelectedLevel: Int = 0
    
    // Use to not allow user to get the auto rotation
    override var shouldAutorotate: Bool {
        return false
    }
    
    override func viewDidLoad() {
        print("MemoVC")
        // make app to have light theme
        overrideUserInterfaceStyle = .light
        // lock to portrait
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        super.viewDidLoad()
        print("date: \(date)")
        dateToHourMin(date: date)
        alarmDatas = alarmDataModel.loadAlarmDatas()
        numberAlarms = alarmDatas!.count
        for i in 0..<numberAlarms {
            if((alarmDatas![i].hour == hour) && (alarmDatas![i].minute == minute) && (alarmDatas![i].enabled) ){
                print("find ringing alarm")
                missionNumber = alarmDatas![i].missionNumber
                missionLevel = alarmDatas![i].missionLevel
                alarmIndex = i
            }
        }
        // load mission level from realm
        setEachLevelTilesToShow(missionLevel: missionLevel)
        setTargetTiles(missionLevel: missionLevel)
        showTargetTilesToUser(missionLevel: missionLevel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
    }
    
    // MARK: - function to manage tiles
    // hide all tiles on the scene
    func hideAllTiles(){
        for i in 0..<totalTile {
            arrayTotalBtn[i].isHidden = true
        }
    }
    
    // set tiles in each level to have grey color
    func setEachLevelTilesToShow(missionLevel: String){
        switch missionLevel {
        // level: normal 4 x 4
        case "normal":
            rememberTime = 5
            targetRightTiles = 5
            totalTileInSelectedLevel = 16
            hideAllTiles()
            stackView5.removeFromSuperview()
            for i in 0...3 {
                for j in 0...3 {
                    arrayTotalBtn[i+(j*5)].layer.cornerRadius = 15
                    arrayTotalBtn[i+(j*5)].isHidden = false
                }
            }
        // level: hard 5 x 5
        case "hard":
            rememberTime = 6
            targetRightTiles = 7
            totalTileInSelectedLevel = 25
            for i in 0..<totalTile {
                arrayTotalBtn[i].layer.cornerRadius = 15
            }
        // easy is the default: 3 x 3
        default:
            rememberTime = 4
            targetRightTiles = 3
            totalTileInSelectedLevel = 9
            hideAllTiles()
            stackView4.removeFromSuperview()
            stackView5.removeFromSuperview()
            for i in 0...2 {
                for j in 0...2 {
                    arrayTotalBtn[i+(j*5)].layer.cornerRadius = 15
                    arrayTotalBtn[i+(j*5)].isHidden = false
                }
            }
        }
    }
    
    // set the number of right tile
    func setTargetTiles(missionLevel: String) {
        switch missionLevel {
        // level: normal 4 x 4
        case "normal":
            var tiles: [Int] =
                [0, 1, 2, 3,
                 5, 6, 7, 8,
                 10, 11, 12, 13,
                 15, 16, 17, 18]
            for i in 0...3 {
                rightTilesSet[i] = Int.random(in: (i*5)...(i*5)+3)
            }
            var randomNumber = Int.random(in: 0..<totalTileInSelectedLevel)
            rightTilesSet[4] = tiles[randomNumber]
            while((rightTilesSet[4]==rightTilesSet[0])||(rightTilesSet[4]==rightTilesSet[1])||(rightTilesSet[4]==rightTilesSet[2])||(rightTilesSet[4]==rightTilesSet[3])){
                randomNumber = Int.random(in: 0..<totalTileInSelectedLevel)
                rightTilesSet[4] = tiles[randomNumber]
            }
        // level: hard 5 x 5
        case "hard":
            for i in 0...4 {
                rightTilesSet[i] = Int.random(in: (i*5)...(i*5)+4)
            }
            rightTilesSet[5] = Int.random(in: 0..<totalTile)
            while((rightTilesSet[5]==rightTilesSet[0])||(rightTilesSet[5]==rightTilesSet[1])||(rightTilesSet[5]==rightTilesSet[2])||(rightTilesSet[5]==rightTilesSet[3])||(rightTilesSet[5]==rightTilesSet[4])){
                rightTilesSet[5] = Int.random(in: 0..<totalTile)
            }
            rightTilesSet[6] = Int.random(in: 0..<totalTile)
            while((rightTilesSet[6]==rightTilesSet[0])||(rightTilesSet[6]==rightTilesSet[1])||(rightTilesSet[6]==rightTilesSet[2])||(rightTilesSet[6]==rightTilesSet[3])||(rightTilesSet[6]==rightTilesSet[4])||(rightTilesSet[6]==rightTilesSet[5])){
                rightTilesSet[6] = Int.random(in: 0..<totalTile)
            }
        // easy is the default: 3 x 3
        default:
            for i in 0...2 {
                rightTilesSet[i] = Int.random(in: (i*5)...(i*5)+2)
            }
        }
    }
    
    // to show green tiles to user
    func showTargetTilesToUser(missionLevel: String) {
        // set the label
        rememberTimeLabel.isHidden = false
        missionLabel.text = "Game: \(countMission + 1)/ \(missionNumber)"
        gameStatusLabel.text = "Memorize\nposition of green tiles"
        // reset variables
        progressBar.progress = 1
        progressBarTimer?.invalidate()
        secondsPassed = 0
        rememberTimePassed = 0
        clickedIndex = 0
        numRightTiles = 0
        // set the tiles
        for i in 0..<totalTile {
            arrayTotalBtn[i].backgroundColor = UIColor(named: "mediumGrey")
            // make a user to cannot select tile
            arrayTotalBtn[i].isEnabled = false
            for j in 0..<targetRightTiles {
                if(rightTilesSet[j] == arrayTotalBtn[i].tag) {
                    arrayTotalBtn[i].backgroundColor = UIColor(named: "lightGreen")
                }
            }
        }
        
        // update progressBar to notice remeberTime to user
        progressBarTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateRememberTimeProgressBarTimer), userInfo: nil, repeats: true)
        
        // delay for user to remember green tiles' position
        var showTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(rememberTime), repeats: false) { [self] _ in
            progressBarTimer?.invalidate()
            rememberTimeLabel.isHidden = true
            gameStatusLabel.text = "Select green tiles"
            soundPlayer.playSound(selectedSound: "MissionComplete")
            for j in 0..<totalTile {
                arrayTotalBtn[j].backgroundColor = UIColor(named: "mediumGrey")
                // allow a user to cannot select tile
                arrayTotalBtn[j].isEnabled = true
            }
            // update progressBar to notice limitTime to user
            progressBarTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateProgressBarTimer), userInfo: nil, repeats: true)
        }
    }
    
    @IBAction func pressedTileBtn(_ sender: UIButton) {
        secondsPassed = 0
        sender.backgroundColor = UIColor.red
        for i in 0..<targetRightTiles {
            // user select a green tile
            if(sender.tag == rightTilesSet[i]){
                // change gameStatus label to Keep tapping
                gameStatusLabel.text = "Keep tapping"
                sender.backgroundColor = UIColor(named: "lightGreen")
                numRightTiles += 1
                isUserSelectedRightTile = true
                break
            }
        }
        // update click index
        clickedIndex += 1
        sender.isEnabled = false
        if(targetRightTiles == clickedIndex){
            if(targetRightTiles == numRightTiles) {
                // change gameStatus label to Keep tapping
                gameStatusLabel.text = "Good job!"
                // invalidate progreenBarTimer
                progressBarTimer?.invalidate()
                countMission += 1
                //print("countMission: \(countMission)")
                soundPlayer.playSound(selectedSound: "MissionComplete")
            }
            
            var showRightTileTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(showPickedTileTime), repeats: false) { [self] _ in
                setTargetTiles(missionLevel: missionLevel)
                if(countMission < missionNumber) {
                    showTargetTilesToUser(missionLevel: missionLevel)
                }
            }
            
            if(countMission >= missionNumber) {
                reScheduleAlarmAndGoToNextScene()
            }
        }
        
        // user select wrong tile
        if(!isUserSelectedRightTile){
            // invalidate progreenBarTimer
            progressBarTimer?.invalidate()
            soundPlayer.playSound(selectedSound: "MissionFail")
            gameStatusLabel.text = "Try again!"
            for i in 0..<totalTile {
                // make a user to cannot select tile
                arrayTotalBtn[i].isEnabled = false
                for j in 0..<targetRightTiles {
                    if(rightTilesSet[j] == arrayTotalBtn[i].tag) {
                        arrayTotalBtn[i].backgroundColor = UIColor(named: "lightGreen")
                    }
                } 
            }
            
            var showWrongTileTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(showPickedTileTime), repeats: false) { [self] _ in
                setTargetTiles(missionLevel: missionLevel)
                showTargetTilesToUser(missionLevel: missionLevel)
            }
        }
        // reset variable
        isUserSelectedRightTile = false
    }
    
    // assign to next scence
    func reScheduleAlarmAndGoToNextScene() {
        print("reScheduleAlarmAndGoToNextScene")
        // disable alarm case no repeat
        alarmDataModel.disableAlarm(alarmDatas: alarmDatas, index: alarmIndex)
        progressBarTimer?.invalidate()
        // reset value
        // reschedule notification
        AlarmService.instance.reSchedule()
        SelectedScene.instance.goToDailyAlarmInfoVC()
    }
    
    // MARK: - upadate progressBar timer
    @objc func updateProgressBarTimer() {
        if(secondsPassed < timeLimit){
            secondsPassed += 1
            progressBar.progress = Float(timeLimit - secondsPassed) / Float(timeLimit)
        }
        else {
            progressBarTimer?.invalidate()
            SelectedScene.instance.goToStopRingingAlarmVC(date: date)
        }
    }
    
    @objc func updateRememberTimeProgressBarTimer() {
        rememberTimePassed += 1
        progressBar.progress = Float(rememberTime - rememberTimePassed) / Float(rememberTime)
        if(rememberTimePassed == rememberTime){
            progressBarTimer?.invalidate()
        }
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


