////
////  extraHelpForAddEditAlarmViewController.swift
////  Sunomoon
////
////  Created by Luksawee Phansri on 2/12/21.
////
//
//import Foundation
//import UIKit
//import RealmSwift
//
// Test
//// MARK: - the class to manage and assign the obj in RepeatAlarmCell
//class RepeatAlarmCell: UITableViewCell {
//    @IBOutlet weak var sunBtn: UIButton!
//    @IBOutlet weak var monBtn: UIButton!
//    @IBOutlet weak var tueBtn: UIButton!
//    @IBOutlet weak var wedBtn: UIButton!
//    @IBOutlet weak var thurBtn: UIButton!
//    @IBOutlet weak var friBtn: UIButton!
//    @IBOutlet weak var satBtn: UIButton!
//    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        setBtnStyle(btn: sunBtn)
//        setBtnStyle(btn: monBtn)
//        setBtnStyle(btn: tueBtn)
//        setBtnStyle(btn: wedBtn)
//        setBtnStyle(btn: thurBtn)
//        setBtnStyle(btn: friBtn)
//        setBtnStyle(btn: satBtn)
//    }
//    
//    // set button style
//    func setBtnStyle(btn: UIButton) {
//        // set label color
//        btn.setTitleColor(UIColor.black, for: .normal)
//        // set label font
//        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15.0)
//        // set background
//        btn.backgroundColor = .white
//        // set btn radius
//        btn.layer.cornerRadius = 15
//    }
//    
//    // the action after pressing the dayBtn
//    @IBAction func pressedRepeatDayBtn(_ sender: UIButton) {
//        sender.isSelected = !sender.isSelected
//        print("\(String(describing: sender.titleLabel?.text)) is pressed")
//        if(sender.isSelected) {
//            print("\(String(describing: sender.titleLabel?.text)) is selected")
//            sender.backgroundColor = UIColor(named: "selectAddEditAlarmButton")
//            sender.setTitleColor(UIColor.white, for: .normal)
//        } else {
//            print("\(String(describing: sender.titleLabel?.text)) is unselected")
//            sender.backgroundColor = .white
//            sender.setTitleColor(UIColor.black, for: .normal)
//        }
//    }
//}
//
//// MARK: - the class to manage and assign the obj in MissionAlarmCell
//class MissionAlarmCell: UITableViewCell {
//    @IBOutlet weak var offBtn: UIButton!
//    @IBOutlet weak var mathBtn: UIButton!
//    @IBOutlet weak var stepBtn: UIButton!
//    @IBOutlet weak var photoBtn: UIButton!
//    @IBOutlet weak var memoryBtn: UIButton!
//    @IBOutlet weak var shakeBtn: UIButton!
//    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        offBtn.isSelected = true
//        setMissionBtnStyle()
//    }
//    
//    // set button style
//    func setBtnStyle(btn: UIButton) {
//        // set label font
//        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15.0)
//        // set btn radius
//        btn.layer.cornerRadius = 15
//        if(btn.isSelected) {
//            btn.backgroundColor = UIColor(named: "selectAddEditAlarmButton")
//            // set label color
//            btn.setTitleColor(UIColor.white, for: .normal)
//        } else {
//            // set background
//            btn.backgroundColor = .white
//            // set label color
//            btn.setTitleColor(UIColor.black, for: .normal)
//        }
//    }
//    
//    func setMissionBtnStyle() {
//        setBtnStyle(btn: offBtn)
//        setBtnStyle(btn: mathBtn)
//        setBtnStyle(btn: stepBtn)
//        setBtnStyle(btn: photoBtn)
//        setBtnStyle(btn: memoryBtn)
//        setBtnStyle(btn: shakeBtn)
//    }
//    
//    func deselectMissionBtn() {
//        offBtn.isSelected = false
//        mathBtn.isSelected = false
//        stepBtn.isSelected = false
//        photoBtn.isSelected = false
//        memoryBtn.isSelected = false
//        shakeBtn.isSelected = false
//    }
//    
//    // the action after pressing the dayBtn
//    @IBAction func pressedMissionDayBtn(_ sender: UIButton) {
//        deselectMissionBtn()
//        setMissionBtnStyle()
//        sender.isSelected = !sender.isSelected
//        print("\(String(describing: sender.titleLabel?.text)) is pressed")
//        if(sender.isSelected) {
//            print("\(String(describing: sender.titleLabel?.text)) is selected")
//            sender.backgroundColor = UIColor(named: "selectAddEditAlarmButton")
//            sender.setTitleColor(UIColor.white, for: .normal)
//        }
//    }
//    
//    
//}
//
//// MARK: - the class to manage and assign the obj in VolumeAlarmCell
//class VolumeAlarmCell: UITableViewCell {
//    @IBOutlet weak var volumeSlider: UISlider!
//    
//    // funtion to get the value of the volumeSlider
//    @IBAction func slidedVolumeSlider(_ sender: UISlider) {
//        print(volumeSlider.value)
//    }
//}
//
//// MARK: - the class to manage and assign the obj in RepeatAlarmCell
//class DeleteAlarmCell: UITableViewCell {
//    @IBOutlet weak var deleteAlarmBtn: UIButton!
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        setBtnStyle(btn: deleteAlarmBtn)
//    }
//    
//    func setBtnStyle(btn: UIButton) {
//        // set label color
//        btn.setTitleColor(UIColor.white, for: .normal)
//        // set label font
//        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17.0)
//        // set background
//        btn.backgroundColor = .red
//        // set btn radius
//        btn.layer.cornerRadius = 15
//    }
//    
//    @IBAction func pressedDelteAlarmBtn(_ sender: UIButton) {
//        print("\(String(describing: sender.titleLabel?.text)) is pressed")
//    }
//}
//
//// MARK: - the class to manage the LabelAlarmCell
//class LabelAlarmCell: UITableViewCell, UITextFieldDelegate {
//    @IBOutlet weak var labelTextField: UITextField!
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        labelTextField.delegate = self
//    }
//    
//    
//    // func to assign textField when the user press done
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
////        if (labelTextField.text == "") {
////            labelTextField.text = "Alarm"
////        }
//        labelTextField.endEditing(true)
//        return true
//    }
//    
//    // func to check if the textField is empty or not
//    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
//        print("textFieldShouldEndEditingfe")
//        if (labelTextField.text == "") {
//            labelTextField.text = "Alarm"
//        }
//        return true
//    }
//    
//    // func to detemine that the editing is end
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        print("textFieldDidEndEditing")
//        if let alarmLabel = labelTextField.text {
//            print(alarmLabel)
//        }
//    }
//}
