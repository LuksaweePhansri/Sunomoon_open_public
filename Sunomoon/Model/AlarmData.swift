//
//  AlarmData.swift
//  Sunomoon
//
//  Created by Luksawee Phansri on 2/11/21.
//

import Foundation
import RealmSwift
class AlarmData: Object {
    @objc dynamic var date: Date = Date()
    @objc dynamic var hour: Int = 00
    @objc dynamic var minute: Int = 00
    @objc dynamic var enabled: Bool = true
    @objc dynamic var repeatSun: Bool = false
    @objc dynamic var repeatMon: Bool = false
    @objc dynamic var repeatTue: Bool = false
    @objc dynamic var repeatWed: Bool = false
    @objc dynamic var repeatThu: Bool = false
    @objc dynamic var repeatFri: Bool = false
    @objc dynamic var repeatSat: Bool = false
    @objc dynamic var alarmLabel: String = "Alarm"
    @objc dynamic var mission: String = "Off"
    @objc dynamic var alarmSound: String = "Default"
    @objc dynamic var volume: Float = 0.5
    @objc dynamic var vibration: Bool = false
    @objc dynamic var snoozeEnabled: Bool = true
    @objc dynamic var onSnooze: Bool = false
    @objc dynamic var missionNumber: Int = 5
    @objc dynamic var missionLevel: String = "easy"
    
    // use to load data from realm
    func loadAlarmDatas() -> Results<AlarmData> {
        let realm = try! Realm()
        var alarmDatas: Results<AlarmData>?
        alarmDatas = realm.objects(AlarmData.self).sorted(byKeyPath: "minute", ascending: true).sorted(byKeyPath: "hour", ascending: true)
        return alarmDatas!
    }
    
    // use to disable not repeat alarm
    func disableAlarm(alarmDatas: Results<AlarmData>?, index: Int){
        let realm = try! Realm()
        if let alarmData = alarmDatas?[index] {
            if(alarmData.repeatSun == false &&
                alarmData.repeatMon == false &&
                alarmData.repeatTue == false &&
                alarmData.repeatWed == false &&
                alarmData.repeatThu == false &&
                alarmData.repeatFri == false &&
                alarmData.repeatSat == false
            ){
                do {
                    try realm.write {
                        alarmData.enabled = false
                    }
                } catch {
                    print("Cannot update alarm, \(error)")
                }
            }
        }
    }
}
