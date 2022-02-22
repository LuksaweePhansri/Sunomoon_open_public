//
//  AlarmService.swift
//  Sunomoon
//
//  Created by Luksawee Phansri on 5/31/21.
//
import Foundation
import RealmSwift
import UserNotifications
import AVFoundation

class AlarmService: NSObject, UNUserNotificationCenterDelegate {
    static let instance = AlarmService()
    let realm = try! Realm()
    var alarmDatas: Results<AlarmData>?
    var alarmDataModel = AlarmData()
    var player: AVAudioPlayer!
    var currentHour: Int = 00
    var currentMinute: Int = 00
    var currentSecond: Int = 00
    var currentWeekday: Int = 1
    
    var numberEnableAlarms: Int = 0
    var selectedSound: String = "Default"
    var secondOfEachAlarm: [Int] = []
    var listOfSelectedSound: [String] = []
    
    func scheduleAlarmNotification() {
        let userNotificationCenter = UNUserNotificationCenter.current()
        var content = UNMutableNotificationContent()
        var dateComponents = DateComponents()
        var numberAlarms: Int = 0
        var secondFromNowToNextAlarm: Int = 0
        var date: Date = Date()
        
        // assign notification message
        print("scheduleAlarmNotification")
        secondOfEachAlarm.removeAll()
        listOfSelectedSound.removeAll()
        currentHour = 00
        currentMinute = 00
        currentSecond = 00
        currentWeekday = 1
        dateToHourMin(date: date)
        print("Current Time: \(currentHour):\(currentMinute):\(currentSecond), \(currentWeekday)")
        numberEnableAlarms = 0
        
        // remove all of notifications
        userNotificationCenter.removeAllPendingNotificationRequests()
        userNotificationCenter.removeAllDeliveredNotifications()
        
        // load data from realm
        alarmDatas = alarmDataModel.loadAlarmDatas()
        if(alarmDatas!.count != 0) {
            numberAlarms = alarmDatas!.count
            print("number of alarm: \(numberAlarms)")
            for i in 0..<numberAlarms {
                // get enable alarm
                if(alarmDatas![i].enabled == true) {
                    content = setContent(sound: alarmDatas![i].alarmSound)
                    numberEnableAlarms += 1
                    //check repeat
                    if((alarmDatas![i].repeatSun == false) && (alarmDatas![i].repeatMon == false) && (alarmDatas![i].repeatTue == false) &&
                        (alarmDatas![i].repeatWed == false) && (alarmDatas![i].repeatThu == false) && (alarmDatas![i].repeatFri == false) &&
                        (alarmDatas![i].repeatSat == false)) {
                        dateComponents = setDateComponentsNoWeekday(hour: alarmDatas![i].hour, min: alarmDatas![i].minute)
                        addUserNotificationCenterStack(dateComponents: dateComponents, content: content)
                        
                        // secondFromNowToThisAlarm
                        var secondFromNowToThisAlarm: Int = 0
                        secondFromNowToThisAlarm = ((alarmDatas![i].hour - currentHour) * 3600) + ((alarmDatas![i].minute - currentMinute) * 60) - currentSecond
                        if(secondFromNowToThisAlarm < 0) {
                            secondFromNowToThisAlarm += 216000
                        }
                        secondOfEachAlarm.append(secondFromNowToThisAlarm)
                        print("secondFromNowToThisAlarm: \(secondFromNowToThisAlarm)")
                        listOfSelectedSound.append(alarmDatas![i].alarmSound)
                    } else {
                        if(alarmDatas![i].repeatSun == true){
                            dateComponents = setDateComponentsWithWeekday(hour: alarmDatas![i].hour, min: alarmDatas![i].minute, weekday: 1)
                            addUserNotificationCenterStack(dateComponents: dateComponents, content: content)
                            addToSecondOfEachAlarm(hour: alarmDatas![i].hour, min: alarmDatas![i].minute, weekday: 1)
                            listOfSelectedSound.append(alarmDatas![i].alarmSound)
                        }
                        if(alarmDatas![i].repeatMon == true){
                            dateComponents = setDateComponentsWithWeekday(hour: alarmDatas![i].hour, min: alarmDatas![i].minute, weekday: 2)
                            addUserNotificationCenterStack(dateComponents: dateComponents, content: content)
                            addToSecondOfEachAlarm(hour: alarmDatas![i].hour, min: alarmDatas![i].minute, weekday: 2)
                            listOfSelectedSound.append(alarmDatas![i].alarmSound)
                        }
                        if(alarmDatas![i].repeatTue == true){
                            dateComponents = setDateComponentsWithWeekday(hour: alarmDatas![i].hour, min: alarmDatas![i].minute, weekday: 3)
                            addUserNotificationCenterStack(dateComponents: dateComponents, content: content)
                            addToSecondOfEachAlarm(hour: alarmDatas![i].hour, min: alarmDatas![i].minute, weekday: 3)
                            listOfSelectedSound.append(alarmDatas![i].alarmSound)
                        }
                        if(alarmDatas![i].repeatWed == true){
                            dateComponents = setDateComponentsWithWeekday(hour: alarmDatas![i].hour, min: alarmDatas![i].minute, weekday: 4)
                            addUserNotificationCenterStack(dateComponents: dateComponents, content: content)
                            addToSecondOfEachAlarm(hour: alarmDatas![i].hour, min: alarmDatas![i].minute, weekday: 4)
                            listOfSelectedSound.append(alarmDatas![i].alarmSound)
                        }
                        if(alarmDatas![i].repeatThu == true){
                            dateComponents = setDateComponentsWithWeekday(hour: alarmDatas![i].hour, min: alarmDatas![i].minute, weekday: 5)
                            addUserNotificationCenterStack(dateComponents: dateComponents, content: content)
                            addToSecondOfEachAlarm(hour: alarmDatas![i].hour, min: alarmDatas![i].minute, weekday: 5)
                            listOfSelectedSound.append(alarmDatas![i].alarmSound)
                        }
                        if(alarmDatas![i].repeatFri == true){
                            dateComponents = setDateComponentsWithWeekday(hour: alarmDatas![i].hour, min: alarmDatas![i].minute, weekday: 6)
                            addUserNotificationCenterStack(dateComponents: dateComponents, content: content)
                            addToSecondOfEachAlarm(hour: alarmDatas![i].hour, min: alarmDatas![i].minute, weekday: 6)
                            listOfSelectedSound.append(alarmDatas![i].alarmSound)
                        }
                        if(alarmDatas![i].repeatSat == true){
                            dateComponents = setDateComponentsWithWeekday(hour: alarmDatas![i].hour, min: alarmDatas![i].minute, weekday: 7)
                            addUserNotificationCenterStack(dateComponents: dateComponents, content: content)
                            addToSecondOfEachAlarm(hour: alarmDatas![i].hour, min: alarmDatas![i].minute, weekday: 7)
                            listOfSelectedSound.append(alarmDatas![i].alarmSound)
                        }
                    }
                }
            }
            print("enable alarm: \(numberEnableAlarms)")
        }
        
        // get the closest alarm and selected sound
        // NEED TO CHECK THIS FUNC
        if(numberAlarms > 0)&&(numberEnableAlarms >= 1){
            print("numberAlarms \(numberAlarms)")
            print("secondOfEachAlarm: \(secondOfEachAlarm)")
            for i in 0..<secondOfEachAlarm.count - 1 {
                if(secondOfEachAlarm[i+1] < secondOfEachAlarm[i]){
                    secondFromNowToNextAlarm = secondOfEachAlarm[i+1]
                    selectedSound = listOfSelectedSound[i+1]
                }
            }
            if(secondOfEachAlarm.count == 1){
                secondFromNowToNextAlarm = secondOfEachAlarm[0]
                selectedSound = listOfSelectedSound[0]
            }
        }
        
        print("alarm in \(secondFromNowToNextAlarm) seconds with sound: \(selectedSound) ")
        
        // to make sound even though an iphone is mute
        let alarmSound = Bundle.main.url(forResource: selectedSound, withExtension: "mp3")
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try! AVAudioPlayer(contentsOf: alarmSound!)
            if(secondFromNowToNextAlarm > 0){
                player.play(atTime: player.deviceCurrentTime + Double(secondFromNowToNextAlarm))
                player.numberOfLoops = -1
                print("make sound")
            }
            
            if(numberAlarms == 0){
                player.stop()
                print("should no more alarm")
            }
        } catch {
            print(error)
        }
        
        print("Find enable alarms: \(numberEnableAlarms)")
        userNotificationCenter.getDeliveredNotifications (completionHandler: {deliveredNotifications -> () in
            print("\(deliveredNotifications.count) Delivered notifications-------")
            for notification in deliveredNotifications{
                print(notification.request.trigger)
            }
        })
        
        userNotificationCenter.getPendingNotificationRequests (completionHandler: {pendingdNotifications -> () in
            print("\(pendingdNotifications.count) Pendingdnotifications-------")
            for notification in pendingdNotifications{
                //                print(notification.identifier)
                print(notification.trigger)
            }
        })
    }
    
    func addUserNotificationCenterStack(dateComponents: DateComponents, content: UNMutableNotificationContent) {
        let userNotificationCenter = UNUserNotificationCenter.current()
        var trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        userNotificationCenter.add(request)
    }
    
    func setDateComponentsNoWeekday(hour: Int, min: Int) -> DateComponents {
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = min
        dateComponents.second = 0
        return dateComponents
    }
    
    func setDateComponentsWithWeekday(hour: Int, min: Int, weekday: Int) -> DateComponents {
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = min
        dateComponents.second = 0
        dateComponents.weekday = weekday
        return dateComponents
    }
    
    func setContent(sound: String) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Hello"
        content.body =  "It is a good time to wake up"
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData": "fizzbuzz"]
        content.sound = UNNotificationSound.init(named:UNNotificationSoundName(rawValue: sound + ".mp3"))
        print("setContent sound: \(sound)")
        return content
    }
    
    // it does not use???
    func registerCatergoies() {
        print("registerCatergoies")
        let userNotificationCenter = UNUserNotificationCenter.current()
        userNotificationCenter.delegate = self
        let show = UNNotificationAction(identifier: "show", title: "Tell me more…", options: .foreground)
        let category = UNNotificationCategory(identifier: "alarm", actions: [show], intentIdentifiers: [])
        userNotificationCenter.setNotificationCategories([category])
    }
    
    func reSchedule() {
        let userNotificationCenter = UNUserNotificationCenter.current()
        userNotificationCenter.removeAllDeliveredNotifications()
        userNotificationCenter.removeAllPendingNotificationRequests()
    }
    
    func dateToHourMin(date: Date) {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        let hr = calendar.component(.hour, from: date)
        let min = calendar.component(.minute, from: date)
        let second = calendar.component(.second, from: date)
        currentHour = hr
        currentMinute = min
        currentWeekday = weekday
        currentSecond = second
        print("Time now: \(hr):\(min):\(second)")
    }
    
    func stopSound(){
        if(player != nil){
            player.stop()
        }
    }
    
    func getsecondFromNowToThisAlarmWithWeekday(hour: Int, min: Int, weekday: Int) -> Int {
        // secondFromNowToThisAlarm
        var secondFromNowToThisAlarm: Int = 0
        secondFromNowToThisAlarm = ((hour - currentHour) * 3600) + ((min - currentMinute) * 60) - currentSecond
        if((weekday - currentWeekday) > 0){
            secondFromNowToThisAlarm += ((weekday - currentWeekday) * 86400)
        }
        else if((weekday - currentWeekday) < 0){
            secondFromNowToThisAlarm += ((weekday - currentWeekday + 7) * 86400)
        }
        else if((weekday - currentWeekday) == 0){
            if(secondFromNowToThisAlarm < 0) {
                secondFromNowToThisAlarm += 604800
            }
        }
        print("second to alarm: \(secondFromNowToThisAlarm)")
        return secondFromNowToThisAlarm
    }
    
    func addToSecondOfEachAlarm(hour: Int, min: Int, weekday: Int) {
        var secondFromNowToThisAlarm = getsecondFromNowToThisAlarmWithWeekday(hour: hour, min: min, weekday: weekday)
        secondOfEachAlarm.append(secondFromNowToThisAlarm)
    }
}
