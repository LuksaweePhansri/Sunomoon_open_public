////
////  AddEditAlarmViewController.swift
////  Sunomoon
////
////  Created by Luksawee Phansri on 1/26/21.
////
//
//import Foundation
//import UIKit
//import RealmSwift
//
//// MARK: - Main class to manage the AddEditAlarmView Controller
//class EditAlarmViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
//    @IBOutlet weak var datePicker: UIDatePicker!
//    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var saveBtn: UIBarButtonItem!
//    let newAlarmData = AlarmData()
//
//    @IBOutlet weak var monBtn: UIButton!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        tableView.dataSource = self
//        tableView.delegate = self
//        // set datePicker color
//        datePicker.setValue(UIColor.black, forKeyPath: "textColor")
//        datePicker.backgroundColor = .white
//        self.datePicker.layer.cornerRadius = 25
//        self.datePicker.layer.masksToBounds = true
//        selectedDatePicker(self.datePicker)
//        //Looks for single or multiple taps.
//        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
//        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
//        //tap.cancelsTouchesInView = false
//        view.addGestureRecognizer(tap)
//    }
//    //Calls this function when the tap is recognized.
//    @objc func dismissKeyboard() {
//        //Causes the view (or one of its embedded text fields) to resign the first responder status.
//        view.endEditing(true)
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        tableView.reloadData()
//        super.viewWillAppear(animated)
//    }
//
//    @IBAction func pressedSaveBtn(_ sender: UIBarButtonItem) {
//        print("pressed save btn")
//
//        self.performSegue(withIdentifier: "saveAddEditAlarmSegue", sender: self)
//        print("in saveBtn \(newAlarmData.date)")
//    }
//
//    @IBAction func selectedDatePicker(_ sender: UIDatePicker) {
//        print("Time from picker in green land: \(sender.date)")
//        newAlarmData.date = sender.date
//
////        let dateFormatter = DateFormatter()
////        // get the date
////        //dateFormatter.dateStyle = DateFormatter.Style.short
////        // get time
////        dateFormatter.timeStyle = DateFormatter.Style.short
////        let strDate = dateFormatter.string(from: datePicker.date)
////        print(strDate)
//    }
//
//    // MARK: - TableView DataSource Method
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if(indexPath.section == 0) {
//            switch indexPath.row {
//            case 0, 2:
//                return 115
//            case 1:
//                return 65
//            case 4:
//                return 85
//            default:
//                return 55
//            }
//        } else {
//            return 50
//        }
//    }
//
//    // func to specify the number of the prototype cell
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 2
//    }
//
//    // set number of table cell
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if(section == 0) {
//            return 7
//        } else {
//            return 1
//        }
//    }
//
//    // specify each text label in each cell
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if(indexPath.section == 0) {
//            switch indexPath.row {
//            case 0:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "repeatAlarmCell", for: indexPath) as! RepeatAlarmCell
//                cell.backgroundColor = UIColor(named: "addEditAlarmBG")
//                return cell
//            case 1:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "labelAlarmCell", for: indexPath) as! LabelAlarmCell
//                cell.backgroundColor = UIColor(named: "addEditAlarmBG")
//                if(cell.isSelected) {
//                    tableView.reloadData()
//                }
//                return cell
//            case 2:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "missionAlarmCell", for: indexPath) as! MissionAlarmCell
//                cell.backgroundColor = UIColor(named: "addEditAlarmBG")
//                return cell
//            case 3:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "soundAlarmCell", for: indexPath)
//                cell.backgroundColor = UIColor(named: "addEditAlarmBG")
//                return cell
//            case 4:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "volumeAlarmCell", for: indexPath) as! VolumeAlarmCell
//                cell.backgroundColor = UIColor(named: "addEditAlarmBG")
//                print(cell.volumeSlider.value)
//                return cell
//            case 5:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "vibrationAlarmCell", for: indexPath)
//                cell.backgroundColor = UIColor(named: "addEditAlarmBG")
//                let switchView = UISwitch(frame: .zero)
//                switchView.setOn(false, animated: true)
//                // assign switchView onset color
//                switchView.onTintColor = UIColor(named: "selectAddEditAlarmButton" )
//                //switchView.thumbTintColor = UIColor(named: "alarmTextColor" )
//                switchView.tag = indexPath.row
//                switchView.addTarget(self, action: #selector(self.vibrationSet(_:)), for: .valueChanged)
//                cell.accessoryView = switchView
//                return cell
//            case 6:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "snoozeAlarmCell", for: indexPath)
//                cell.backgroundColor = UIColor(named: "addEditAlarmBG")
//                let switchView = UISwitch(frame: .zero)
//                switchView.setOn(false, animated: true)
//                // assign switchView onset color
//                switchView.onTintColor = UIColor(named: "selectAddEditAlarmButton" )
//                //switchView.thumbTintColor = UIColor(named: "alarmTextColor" )
//                switchView.tag = indexPath.row
//                switchView.addTarget(self, action: #selector(self.snoozeSet(_:)), for: .valueChanged)
//                cell.accessoryView = switchView
//                return cell
//            default:
//                let cell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "errorAlarmCell")
//                cell.backgroundColor = UIColor(named: "addEditAlarmBG")
//                cell.textLabel?.text = "Error Issue!!"
//            }
//        } else if(indexPath.section == 1) {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "deleteAlarmCell", for: indexPath)
//            cell.backgroundColor = UIColor(named: "addEditAlarmBG")
//            return cell
//        }
//
//        var cell = tableView.dequeueReusableCell(withIdentifier: "SettingAlarmCell")
//        if(cell == nil) {
//            // initialize tableViewCell with the reuseIdentifier: "SettingAlarmCell"
//            cell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "SettingAlarmCell")
//            cell?.backgroundColor = UIColor(named: "addEditAlarmBG")
//        }
//        return cell!
//    }
//
//    @objc func snoozeSet(_ sender : UISwitch!){
//        print("The snooze is \(sender.isOn ? "ON" : "OFF")")
//    }
//
//    @objc func vibrationSet(_ sender : UISwitch!){
//        print("The vibration is \(sender.isOn ? "ON" : "OFF")")
//    }
//
//    //Mark: - Tableview Delegate Methods
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if(indexPath.row == 0) {
//            print("select row1")
//        }
//    }
//}
//
//
//
//
//
//
//
