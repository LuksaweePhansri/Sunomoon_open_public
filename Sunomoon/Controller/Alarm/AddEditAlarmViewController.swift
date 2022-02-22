//
//  AddEditAlarmViewController.swift
//  Sunomoon
//
//  Created by Luksawee Phansri on 1/26/21.
//

import Foundation
import UIKit
import RealmSwift
class AddEditAlarmViewController: UITableViewController, UITextFieldDelegate {
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var saveBtn: UIBarButtonItem!
    @IBOutlet weak var sunBtn: UIButton!
    @IBOutlet weak var monBtn: UIButton!
    @IBOutlet weak var tueBtn: UIButton!
    @IBOutlet weak var wedBtn: UIButton!
    @IBOutlet weak var thurBtn: UIButton!
    @IBOutlet weak var friBtn: UIButton!
    @IBOutlet weak var satBtn: UIButton!
    @IBOutlet weak var offBtn: UIButton!
    @IBOutlet weak var mathBtn: UIButton!
    @IBOutlet weak var typingBtn: UIButton!
    @IBOutlet weak var squatBtn: UIButton!
    @IBOutlet weak var memoryBtn: UIButton!
    @IBOutlet weak var shakeBtn: UIButton!
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var labelTextField: UITextField!
    @IBOutlet weak var snoozeSwitch: UISwitch!
    @IBOutlet weak var alarmVibrationSwitch: UISwitch!
    @IBOutlet weak var deleteAlarmBtn: UIButton!
    @IBOutlet weak var soundNameBtn: UIButton!
    
    // load data rom Realm
    let realm = try! Realm()
    var alarmDatas: Results<AlarmData>?
    var alarmDataModel = AlarmData()
    var isEditingMode: Bool = false
    var selectedAlarmInfo: SelectedAlarmInfo!
    
    // var that will use to set alarm
    var date: Date = Date()
    var hour: Int = 00
    var minute: Int = 00
    var enabled: Bool = true
    var repeatSun: Bool = false
    var repeatMon: Bool = false
    var repeatTue: Bool = false
    var repeatWed: Bool = false
    var repeatThu: Bool = false
    var repeatFri: Bool = false
    var repeatSat: Bool = false
    var alarmLabel: String = "Alarm"
    var mission: String = "Off"
    var alarmSound: String = "Default"
    var volume: Float = 0.5
    var vibration: Bool = true
    var snoozeEnabled: Bool = true
    var onSnooze: Bool = false
    var missionNumber: Int = 5
    var missionLevel: String = "easy"
    
    // Use to not allow user to get the auto rotation
    override var shouldAutorotate: Bool {
        return false
    }
    
    override func viewDidLoad() {
        print("AddEditAlarmVC")
        // make app to have light theme
        overrideUserInterfaceStyle = .light
        // lock to portrait
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        // load data from realm
        alarmDatas = alarmDataModel.loadAlarmDatas()
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        //tableView.translatesAutoresizingMaskIntoConstraints = false
        // set datePicker color
        datePicker.setValue(UIColor.black, forKeyPath: "textColor")
        datePicker.backgroundColor = .white
        self.datePicker.layer.cornerRadius = 25
        self.datePicker.layer.masksToBounds = true
        if(isEditingMode){
            if(alarmDatas?[selectedAlarmInfo.alarmIndex]) != nil {
                title = "Edit Alarm"
                datePicker.date = alarmDatas![selectedAlarmInfo.alarmIndex].date
                date = alarmDatas![selectedAlarmInfo.alarmIndex].date
                dateToHourMin(date: date)
                sunBtn.isSelected = alarmDatas![selectedAlarmInfo.alarmIndex].repeatSun
                repeatSun = sunBtn.isSelected
                monBtn.isSelected = alarmDatas![selectedAlarmInfo.alarmIndex].repeatMon
                repeatMon = monBtn.isSelected
                tueBtn.isSelected = alarmDatas![selectedAlarmInfo.alarmIndex].repeatTue
                repeatTue = tueBtn.isSelected
                wedBtn.isSelected = alarmDatas![selectedAlarmInfo.alarmIndex].repeatWed
                repeatWed = wedBtn.isSelected
                thurBtn.isSelected = alarmDatas![selectedAlarmInfo.alarmIndex].repeatThu
                repeatThu = thurBtn.isSelected
                friBtn.isSelected = alarmDatas![selectedAlarmInfo.alarmIndex].repeatFri
                repeatFri = friBtn.isSelected
                satBtn.isSelected = alarmDatas![selectedAlarmInfo.alarmIndex].repeatSat
                repeatSat = satBtn.isSelected
                labelTextField.text = alarmDatas![selectedAlarmInfo.alarmIndex].alarmLabel
                mission = alarmDatas![selectedAlarmInfo.alarmIndex].mission
                switch mission {
                case "Off":
                    offBtn.isSelected = true
                case "Math":
                    mathBtn.isSelected = true
                case "Typing":
                    typingBtn.isSelected = true
                case "Squat":
                    squatBtn.isSelected = true
                case "Memo":
                    memoryBtn.isSelected = true
                case "Shake":
                    shakeBtn.isSelected = true
                default:
                    offBtn.isSelected = true
                }
                alarmSound = alarmDatas![selectedAlarmInfo.alarmIndex].alarmSound
                volumeSlider.value = alarmDatas![selectedAlarmInfo.alarmIndex].volume
                volume = volumeSlider.value
                alarmVibrationSwitch.isOn = alarmDatas![selectedAlarmInfo.alarmIndex].vibration
                vibration = alarmVibrationSwitch.isOn
                snoozeEnabled = alarmDatas![selectedAlarmInfo.alarmIndex].snoozeEnabled
                snoozeSwitch.isOn = snoozeEnabled
                onSnooze = alarmVibrationSwitch.isOn
                missionNumber = alarmDatas![selectedAlarmInfo.alarmIndex].missionNumber
                missionLevel = alarmDatas![selectedAlarmInfo.alarmIndex].missionLevel
            }
        }
        // set date case add new alarm
        if(!isEditingMode){
            title = "Add Alarm"
            date = datePicker.date
            dateToHourMin(date: date)
            offBtn.isSelected = true
        }
        selectedDatePicker(self.datePicker)
        labelTextField.delegate = self
        //Looks for single or multiple taps.
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        setRepeatBtnStyle()
        setRepeatBtnStyle()
        setMissionBtnStyle()
        setDeleteBtnStyle(btn: deleteAlarmBtn)
        
        //alarmVibrationSwitch.setOn(false, animated: true)
        // assign switchView onset color
        alarmVibrationSwitch.onTintColor = UIColor(named: "selectAddEditAlarmButton" )
        //alarmVibrationSwitch.setOn(false, animated: true)
        // assign switchView onset color
        snoozeSwitch.onTintColor = UIColor(named: "selectAddEditAlarmButton" )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        soundNameBtn.setTitle(alarmSound, for: .normal)
        tableView.reloadData()
        super.viewWillAppear(animated)
        // lock to portrait
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Reset when view is being removed
        AppUtility.lockOrientation(.portrait)
    }
    
    
    // MARK: - acction when user click each btn
    @IBAction func selectedDatePicker(_ sender: UIDatePicker) {
        date = datePicker.date
        dateToHourMin(date: date)
    }
    
    // the action after pressing the dayBtn
    @IBAction func pressedRepeatDayBtn(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        //print("\(String(describing: sender.titleLabel?.text)) is pressed")
        if(sender.isSelected) {
            sender.backgroundColor = UIColor(named: "selectAddEditAlarmButton")
            sender.setTitleColor(UIColor.white, for: .normal)
            switch sender.currentTitle {
            case "Sun":
                repeatSun = true
            case "Mon":
                repeatMon = true
            case "Tue":
                repeatTue = true
            case "Wed":
                repeatWed = true
            case "Thu":
                repeatThu = true
            case "Fri":
                repeatFri = true
            case "Sat":
                repeatSat = true
            default:
                print("Error")
            }
        } else {
            sender.backgroundColor = .white
            sender.setTitleColor(UIColor.black, for: .normal)
            switch sender.currentTitle {
            case "Sun":
                repeatSun = false
            case "Mon":
                repeatMon = false
            case "Tue":
                repeatTue = false
            case "Wed":
                repeatWed = false
            case "Thu":
                repeatThu = false
            case "Fri":
                repeatFri = false
            case "Sat":
                repeatSat = false
            default:
                print("Error")
            }
        }
    }
    
    // funtion to get the value of the volumeSlider
    @IBAction func slidedVolumeSlider(_ sender: UISlider) {
        volume = volumeSlider.value
    }
    
    // func to set the alarm vibration
    @IBAction func changeAlarmVibrationSwitch(_ sender: Any) {
        if(alarmVibrationSwitch.isOn) {
            vibration = true
        } else {
            vibration = false
        }
    }
    
    // call function sound
    @IBAction func pressedSound(_ sender: Any) {
        self.performSegue(withIdentifier: "goSoundAlarmViewControllerSegue", sender: self)
    }
    
    // func to set the enable/disable snooze
    @IBAction func changeSnoozeSwitch(_ sender: Any) {
        if(mission == "Off") {
            if(snoozeSwitch.isOn) {
                snoozeEnabled = true
            } else {
                snoozeEnabled = false
            }
        } else {
            snoozeSwitch.isOn = false
            snoozeEnabled = false
        }
    }
    
    @IBAction func pressedSaveBtn(_ sender: UIBarButtonItem) {
        var newAlarmData = AlarmData()
        newAlarmData.date = date
        newAlarmData.hour = hour
        newAlarmData.minute = minute
        newAlarmData.repeatSun = repeatSun
        newAlarmData.repeatMon = repeatMon
        newAlarmData.repeatTue = repeatTue
        newAlarmData.repeatWed = repeatWed
        newAlarmData.repeatThu = repeatThu
        newAlarmData.repeatFri = repeatFri
        newAlarmData.repeatSat = repeatSat
        newAlarmData.alarmLabel = labelTextField.text  ?? alarmLabel
        newAlarmData.mission = mission
        newAlarmData.alarmSound = alarmSound
        newAlarmData.volume = volume
        newAlarmData.vibration = vibration
        newAlarmData.snoozeEnabled = snoozeEnabled
        newAlarmData.onSnooze = onSnooze
        newAlarmData.missionNumber = missionNumber
        newAlarmData.missionLevel = missionLevel
        // case add new alarm
        if(!isEditingMode){
            addNewAlarm(alarmData: newAlarmData)
        }
        if(isEditingMode) {
            editAlarm(newAlarmData: newAlarmData)
        }
        self.performSegue(withIdentifier: "saveAddEditAlarmSegue", sender: self)
    }
    
    @IBAction func pressedDeleteBtn(_ sender: Any) {
        if(isEditingMode){
            if let alarmData = alarmDatas?[selectedAlarmInfo.alarmIndex] {
                do {
                    try self.realm.write {
                        realm.delete(alarmData)
                    }
                } catch {
                    print("Cannot delete alarm data, \(error)")
                }
                self.performSegue(withIdentifier: "delAddEditAlarmSegue", sender: self)
            }
        }
    }
    
    // the action after pressing the missionBtn
    @IBAction func pressedMissionBtn(_ sender: UIButton) {
        deselectMissionBtn()
        setMissionBtnStyle()
        sender.isSelected = !sender.isSelected
        if(sender.isSelected) {
            if(sender.currentTitle == "Off") {
                snoozeSwitch.isOn = true
                snoozeEnabled = true
            } else {
                snoozeSwitch.isOn = false
                snoozeEnabled = false
            }
            
            if(sender.currentTitle != mission){
                missionLevel = "easy"
                if((sender.currentTitle == "Math") || (sender.currentTitle == "Memo")){
                    missionNumber = 3
                }
                else if(sender.currentTitle == "Typing"){
                    missionNumber = 1
                }
                else {
                    missionNumber = 5
                }
            }
            mission = sender.currentTitle!
            sender.backgroundColor = UIColor(named: "selectAddEditAlarmButton")
            sender.setTitleColor(UIColor.white, for: .normal)
            if(mission != "Off") {
                self.performSegue(withIdentifier: "goSelectAlarmMissionViewControllerSegue", sender: self)
            }
        }
    }
    
    // MARK: - textField
    // func to assign textField when the user press done
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        labelTextField.endEditing(true)
        return true
    }
    
    // func to check if the textField is empty or not
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if (labelTextField.text == "") {
            labelTextField.text = "Alarm"
            alarmLabel = "Alarm"
        }
        return true
    }
    
    // func to detemine that the editing is end
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let label = labelTextField.text {
            alarmLabel = label
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.text = ""
        return true
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
// MARK: - tableView
    // section 8 is no Delete, section 9 is Delete
    override func numberOfSections(in tableView: UITableView) -> Int {
        // add new alarm
        if(!isEditingMode){
            return 8
        }
        // edit alarm
        else{
            return 9
        }
    }
    
    //MARK: - Helper function
    // set button style
    func setBtnStyle(btn: UIButton) {
        // set label font
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15.0)
        // set btn radius
        btn.layer.cornerRadius = 15
        if(btn.isSelected) {
            btn.backgroundColor = UIColor(named: "selectAddEditAlarmButton")
            // set label color
            btn.setTitleColor(UIColor.white, for: .normal)
        } else {
            // set background
            btn.backgroundColor = .white
            // set label color
            btn.setTitleColor(UIColor.black, for: .normal)
        }
    }
    
    // helper for set repeatday btn
    func setRepeatBtnStyle() {
        setBtnStyle(btn: sunBtn)
        setBtnStyle(btn: monBtn)
        setBtnStyle(btn: tueBtn)
        setBtnStyle(btn: wedBtn)
        setBtnStyle(btn: thurBtn)
        setBtnStyle(btn: friBtn)
        setBtnStyle(btn: satBtn)
    }
    
    // helper for mission btn
    func setMissionBtnStyle() {
        setBtnStyle(btn: offBtn)
        setBtnStyle(btn: mathBtn)
        setBtnStyle(btn: typingBtn)
        setBtnStyle(btn: squatBtn)
        setBtnStyle(btn: memoryBtn)
        setBtnStyle(btn: shakeBtn)
    }
    
    // helper for deselect mission btn
    func deselectMissionBtn() {
        offBtn.isSelected = false
        mathBtn.isSelected = false
        typingBtn.isSelected = false
        squatBtn.isSelected = false
        memoryBtn.isSelected = false
        shakeBtn.isSelected = false
    }
    
    // helper for delete btn
    func setDeleteBtnStyle(btn: UIButton) {
        // set label color
        btn.setTitleColor(UIColor.white, for: .normal)
        // set label font
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17.0)
        // set background
        btn.backgroundColor = .red
        // set btn radius
        btn.layer.cornerRadius = 15
    }
    
    // MARK: - prepare segue
    @IBAction func unwindFromSoundAlarmView(_ segue: UIStoryboardSegue) {
        print("go back to AddEditAlarmVC from sound")
    }
    
    @IBAction func unwindFromSelectMissionAlarmView(_ segue: UIStoryboardSegue) {
        print("go back to AddEditAlarmVC from mission")
    }
    
    // used to prepare and store selectedSound and send it back to AddEditAlarmViewController if user press save
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if(segue.identifier == "goSoundAlarmViewControllerSegue"){
            let destinationVC = segue.destination as! SoundAlarmViewController
            destinationVC.currentSound = alarmSound
        }
        if(segue.identifier == "goSelectAlarmMissionViewControllerSegue") {
            let destinationVC = segue.destination as! SelectAlarmMissionViewController
            destinationVC.selectedMission = mission
            destinationVC.selectedMissionNumber = missionNumber
            destinationVC.selectedMissionLevel = missionLevel
        }
    }
    
    //MARK: - Data Manupulation Methods
    func addNewAlarm(alarmData: AlarmData){
        do {
            try realm.write{
                realm.add(alarmData)
            }
        } catch {
            print("Error saving context, \(error)")
        }
    }
    
    func editAlarm(newAlarmData: AlarmData){
        if let alarmData = alarmDatas?[selectedAlarmInfo.alarmIndex] {
            do {
                try realm.write{
                    alarmData.date = newAlarmData.date
                    alarmData.hour = newAlarmData.hour
                    alarmData.minute = newAlarmData.minute
                    alarmData.repeatSun = newAlarmData.repeatSun
                    alarmData.repeatMon = newAlarmData.repeatMon
                    alarmData.repeatTue = newAlarmData.repeatTue
                    alarmData.repeatWed = newAlarmData.repeatWed
                    alarmData.repeatThu = newAlarmData.repeatThu
                    alarmData.repeatFri = newAlarmData.repeatFri
                    alarmData.repeatSat = newAlarmData.repeatSat
                    alarmData.alarmLabel = newAlarmData.alarmLabel
                    alarmData.mission = newAlarmData.mission
                    alarmData.alarmSound = newAlarmData.alarmSound
                    alarmData.volume = newAlarmData.volume
                    alarmData.vibration = newAlarmData.vibration
                    alarmData.snoozeEnabled = newAlarmData.snoozeEnabled
                    alarmData.onSnooze = newAlarmData.onSnooze
                    alarmData.missionNumber = newAlarmData.missionNumber
                    alarmData.missionLevel = newAlarmData.missionLevel
                    alarmData.enabled = true
                }
            } catch {
                print("Cannot update alarm, \(error)")
            }
        }
    }
    
    func dateToHourMin(date: Date) {
        let calendar = Calendar.current
        let hr = calendar.component(.hour, from: date)
        let min = calendar.component(.minute, from: date)
        hour = hr
        minute = min
    }
}
