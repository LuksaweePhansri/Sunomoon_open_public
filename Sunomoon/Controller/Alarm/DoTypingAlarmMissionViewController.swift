//
//  DoTypingAlarmMissionViewController.swift
//  Sunomoon
//
//  Created by Luksawee Phansri on 6/23/21.
//

import Foundation
import UIKit
import RealmSwift

class DoTypingAlarmMissionViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var textViewPlaceHolder: UITextView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var authourLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var instructionLabel: UILabel!
    
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
    var alarmIndex: Int = 0
    
    // get quotes
    var quote: String = ""
    var quoteLength: Int = 0
    var motivationQuoteData = MotivationQuoteData()
    var totalMotivationQuotes: Int = 0
    var randomQuotesNumber: Int = 0
    
    // get sound and manage progreesBar
    var soundPlayer = SoundPlayer()
    var progressBarTimer: Timer?
    var secondsPassed = 0
    var timeLimit = 30
    
    // Use to not allow user to get the auto rotation
    override var shouldAutorotate: Bool {
        print("shouldAutorotate")
        return false
    }
    
    override func viewDidLoad() {
        // make app to have light theme
        overrideUserInterfaceStyle = .light
        // lock to portrait
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        super.viewDidLoad()
        textView.delegate = self
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
        // show keyboard
        textView.becomeFirstResponder()
        // assign components in the scence
        prepareQuoteForUserTyping()
        // progressBar timet
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
    
    // MARK: - make the string to change color based on right or wrong user typing
    func textViewDidChange(_ textView: UITextView) {
        // reset time if a user is typing something
        secondsPassed = 0
        // assign random quote
        quote = motivationQuoteData.getQuote(quoteNumber: randomQuotesNumber)
        quoteLength = quote.count
        var userTyping = textView.text
        var userTypingLength = userTyping?.count ?? 0
        
        let regularAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 28), NSAttributedString.Key.foregroundColor: UIColor.black]
        let redAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 28), NSAttributedString.Key.foregroundColor: UIColor.red]
        let greenAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 28), NSAttributedString.Key.foregroundColor: UIColor(named: "lightGreen")]
        let mutableAttributedString = NSMutableAttributedString(string: userTyping ?? "", attributes: regularAttributes)
        
        if((userTypingLength <= quoteLength) && (userTypingLength > 0)) {
            for i in 0..<userTypingLength {
                var index = userTyping?.index(userTyping!.startIndex, offsetBy: i)
                var char = userTyping![index!]
                var string = String(char)
                if(userTyping![index!] != quote[index!]){
                    mutableAttributedString.setAttributes(redAttributes, range: NSRange(location: i, length: 1))
                }
                
                if(userTyping![index!] == quote[index!]) {
                    mutableAttributedString.setAttributes(greenAttributes, range: NSRange(location: i, length: 1))
                }
            }
            textView.attributedText = mutableAttributedString
        }
        
        if((userTypingLength == quoteLength) && (userTyping == quote)){
            countMission += 1
            print("Typing complete")
            prepareQuoteForUserTyping()
            soundPlayer.playSound(selectedSound: "MissionComplete")
            
            if(countMission >= missionNumber ?? 1) {
                reScheduleAlarmAndGoToNextScene()
            }
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
    
    //MARK: - other relate function
    func dateToHourMin(date: Date) {
        let calendar = Calendar.current
        let hr = calendar.component(.hour, from: date)
        let min = calendar.component(.minute, from: date)
        hour = hr
        minute = min
    }
    
    func prepareQuoteForUserTyping() {
        textView.text = ""
        textView.autocapitalizationType = .sentences
        totalMotivationQuotes = motivationQuoteData.getNumberOfQuotes()
        // assign random number
        randomQuotesNumber = Int.random(in: 0..<totalMotivationQuotes)
        textViewPlaceHolder.text = motivationQuoteData.getQuote(quoteNumber: randomQuotesNumber)
        authourLabel.text = motivationQuoteData.getAuthor(quoteNumber: randomQuotesNumber)
        instructionLabel.text = "Typing sentence: \(missionNumber ?? 1 - countMission) / \(missionNumber ?? 1)"
    }
}
