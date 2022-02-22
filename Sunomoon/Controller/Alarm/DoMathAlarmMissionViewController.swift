//
//  DoMathAlarmMissionViewController.swift
//  Sunomoon
//
//  Created by Luksawee Phansri on 6/28/21.
//

import Foundation
import UIKit
import RealmSwift
import AVFoundation

class DoMathAlarmMissionViewController: UIViewController {
    @IBOutlet weak var missionLabel: UILabel!
    @IBOutlet weak var sunPic: UIImageView!
    @IBOutlet weak var mathQuestion: UILabel!
    @IBOutlet weak var negBtn: UIButton!
    @IBOutlet weak var acBtn: UIButton!
    @IBOutlet weak var zeroBtn: UIButton!
    @IBOutlet weak var oneBtn: UIButton!
    @IBOutlet weak var twoBtn: UIButton!
    @IBOutlet weak var threeBtn: UIButton!
    @IBOutlet weak var fourBtn: UIButton!
    @IBOutlet weak var fiveBtn: UIButton!
    @IBOutlet weak var sixBtn: UIButton!
    @IBOutlet weak var sevenBtn: UIButton!
    @IBOutlet weak var eightBtn: UIButton!
    @IBOutlet weak var nineBtn: UIButton!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var sunPicConstraint: NSLayoutConstraint!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var answerLabel: UILabel!
    
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
    var alarmIndex: Int = 0
    
    // var for math questions
    var rightAnswer: Int = 0
    var userAnswer: Int = 0
    var isFinishTypingNumber: Bool = true
    var first2Digit: [Int] = [0, 0]
    var first3Digit: [Int] = [0, 0, 0]
    var second1Digit: Int = 0
    var second2Digit: [Int] = [0, 0]
    var second3Digit: [Int] = [0, 0, 0]
    var operation: [String] = ["+", "-"]
    var stringRightAnswer: String = ""
    var stringFirstDigit: String = ""
    var firstDigit: Int = 0
    var stringSecondDigit: String = ""
    var secondDigit: Int = 0
    
    // get sound and manage progreesBar
    var soundPlayer = SoundPlayer()
    var progressBarTimer: Timer?
    var secondsPassed: Float = 0
    var timeLimit:Float = 15
    
    // Use to not allow user to get the auto rotation
    override var shouldAutorotate: Bool {
        print("shouldAutorotate")
        return false
    }
    
    override func viewDidLoad() {
        print("DoMathAlarmMissionVC")
        // make app to have light theme
        overrideUserInterfaceStyle = .light
        // lock to portrait
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        super.viewDidLoad()
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
        
        setMissionLabel()
        setQuetionAndRightAnswer(missionLevel: missionLevel)
        progressBarTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateProgressBarTimer), userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
    }
    
    // MARK: - upadate progressBar timer
    @objc func updateProgressBarTimer() {
        if(secondsPassed < timeLimit){
            secondsPassed += 1
            progressBar.progress = Float(timeLimit - secondsPassed) / Float(timeLimit)
        }
        else {
            progressBarTimer?.invalidate()
            print("Time up")
            SelectedScene.instance.goToStopRingingAlarmVC(date: date)
        }
    }
    
    // MARK: - random number
    func randomEachDigit(missionLevel: String){
        stringFirstDigit = ""
        stringSecondDigit = ""
        firstDigit = 0
        secondDigit = 0
        switch missionLevel {
        case "normal":
            for i in 0..<2 {
                if(i == 0){
                    first2Digit[i] = randomFirstDigit()
                    second2Digit[i] = randomFirstDigit()
                }
                else {
                    first2Digit[i] = randomOtherDigit()
                    second2Digit[i] = randomOtherDigit()
                }
                stringFirstDigit += String(first2Digit[i])
                stringSecondDigit += String(second2Digit[i])
            }
        case "hard":
            for i in 0..<3 {
                if(i == 0){
                    first3Digit[i] = randomFirstDigit()
                    second3Digit[i] = randomFirstDigit()
                }
                else {
                    first3Digit[i] = randomOtherDigit()
                    second3Digit[i] = randomOtherDigit()
                }
                stringFirstDigit += String(first3Digit[i])
                stringSecondDigit += String(second3Digit[i])
            }
        default:
            for i in 0..<2 {
                if(i == 0){
                    first2Digit[i] = randomFirstDigit()
                }
                else {
                    first2Digit[i] = randomOtherDigit()
                }
                stringFirstDigit += String(first2Digit[i])
            }
            second1Digit = randomFirstDigit()
            stringSecondDigit = String(second1Digit)
        }
        firstDigit = Int((stringFirstDigit as NSString).intValue)
        secondDigit = Int((stringSecondDigit as NSString).intValue)
    }
    
    func randomFirstDigit() -> Int {
        let n: Int = Int.random(in: 1..<10)
        return n
    }
    
    func randomOtherDigit() -> Int {
        let n: Int = Int.random(in: 0..<10)
        return n
    }
    
    func setQuetionAndRightAnswer(missionLevel: String){
        rightAnswer = 0
        randomEachDigit(missionLevel: missionLevel)
        let selectOperation: String = operation[Int.random(in: 0...1)]
        rightAnswer = calRightAnswer(operation: selectOperation, n1: firstDigit, n2: secondDigit)
        stringRightAnswer = String(rightAnswer)
        print(rightAnswer)
        let boldFont = UIFont.boldSystemFont(ofSize: 24)
        let configuration = UIImage.SymbolConfiguration(font: boldFont)

        let image = UIImage(systemName: "book.circle", withConfiguration: configuration)
        mathQuestion.text = "\(stringFirstDigit) \(selectOperation) \(stringSecondDigit)  =  ?"
    }
    
    func setMissionLabel(){
        missionLabel.text = "Questions \n \(countMission + 1)/ \(missionNumber)"
    }
    
    func calRightAnswer(operation: String, n1: Int, n2: Int)-> Int {
        var answer: Int = 0
        switch operation {
        case "-":
            answer = n1 - n2
        default:
            answer = n1 + n2
        }
        print("\(n1) \(operation) \(n2) = \(answer)")
        return answer
    }
    
    
    @IBAction func pressedNumBtn(_ sender: UIButton) {
        secondsPassed = 0
        sunPicConstraint.constant = 20
        sunPicConstraint.isActive = true
        if let numValue = sender.currentTitle {
            if(isFinishTypingNumber) {
                answerLabel.text = numValue
                isFinishTypingNumber = false
            }
            else {
                answerLabel.text = answerLabel.text! + numValue
            }
        }
    }
    
    @IBAction func pressedChangeSignBtn(_ sender: Any) {
        secondsPassed = 0
        userAnswer = Int((answerLabel.text as! NSString).intValue)
        userAnswer = userAnswer * -1
        answerLabel.text = String(userAnswer)
    }
    
    @IBAction func pressedACBtn(_ sender: Any) {
        secondsPassed = 0
        answerLabel.text = ""
        userAnswer = 0
    }
    
    @IBAction func pressedDonetn(_ sender: Any) {
        secondsPassed = 0
        print(answerLabel.text)
        isFinishTypingNumber = true
        if(answerLabel.text != nil){
            userAnswer = Int((answerLabel.text as! NSString).intValue)
            if(userAnswer == rightAnswer){
                sunPic.image = UIImage(named: "sunSmile")
                countMission += 1
                soundPlayer.playSound(selectedSound: "MissionComplete")
            }
            if(userAnswer != rightAnswer){
                sunPicConstraint.constant = -50
                sunPicConstraint.isActive = true
                soundPlayer.playSound(selectedSound: "MissionFail")
            }
        }
        
        setMissionLabel()
        setQuetionAndRightAnswer(missionLevel: missionLevel)
        answerLabel.text = ""
        if(countMission >= missionNumber){
            reScheduleAlarmAndGoToNextScene()
        }
    }
    
    // assign to next scence
    func reScheduleAlarmAndGoToNextScene() {
        print("stop")
        // disable alarm case no repeat
        alarmDataModel.disableAlarm(alarmDatas: alarmDatas, index: alarmIndex)
        progressBarTimer?.invalidate()
        // reset value
        countMission = 0
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
