////
////  AddToCalendarViewController.swift
////  Sunomoon
////
////  Created by Luksawee Phansri on 7/26/21.
////
//
//import Foundation
//import UIKit
//
//// class for customize StartEndTimeCell
//class CustomStartEndTimeCell: UITableViewCell {
//    @IBOutlet weak var stackAll: UIStackView!
//    @IBOutlet weak var stackStart: UIStackView!
//    @IBOutlet weak var stackEnd: UIStackView!
//    @IBOutlet weak var dateStartLabel: UILabel!
//    @IBOutlet weak var timeStartLabel: UILabel!
//    @IBOutlet weak var dateEndLabel: UILabel!
//    @IBOutlet weak var timeEndLabel: UILabel!
//    @IBOutlet weak var startBtn: UIButton!
//    
//}
//
//class AddToCalendarViewController: UIViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource {
//    @IBOutlet weak var textViewPlaceHolder: UITextView!
//    @IBOutlet weak var textView: UITextView!
//    @IBOutlet weak var tableView: UITableView!
//    
//    var showDatePicker: Bool = false
//    var editStartDatePicker: Bool = false
//    var editEndDatePicker: Bool = false
//    var allDayCalendar: Bool = false
//    
//    @IBOutlet weak var tabbar: UITabBar!
//    
//    
//    let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
//    let taskBtn = UIButton(type: .custom)
//    let eventBtn = UIButton(type: .custom)
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        tableView.delegate = self
//        tableView.dataSource = self
//        textView.delegate = self
//        
//        setBackgroundComponents()
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        // Reload table
//        tableView.reloadData()
//    }
//    
//    // MARK: - set components
//    func setBackgroundComponents() {
//        // create bar that will show event, task on the top of keyboard
//        let bar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 40))
//        bar.backgroundColor = UIColor(named: "AccentColor")
//        // eventBtn
//        eventBtn.setImage(UIImage(systemName: "clock.fill"), for: .normal)
//        eventBtn.setTitle("Event", for: .normal)
//        eventBtn.tintColor = .white
//        eventBtn.titleLabel?.font = .boldSystemFont(ofSize: 18)
//        eventBtn.layer.backgroundColor = UIColor(named: "AccentColor")?.cgColor
//        eventBtn.frame.size = CGSize(width: 100, height: 25)
//        eventBtn.layer.cornerRadius = 10
//        eventBtn.addTarget(self, action: #selector(eventSelected), for: .touchUpInside)
//        let eventBarBtn = UIBarButtonItem(customView: eventBtn)
//        // default: select Event
//        eventBtn.isSelected = true
//        // taskBtn
//        taskBtn.setImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
//        taskBtn.setTitle("Task", for: .normal)
//        taskBtn.tintColor = UIColor(named: "AccentColor")
//        taskBtn.setTitleColor(UIColor(named: "AccentColor"), for: .normal)
//        taskBtn.titleLabel?.font = .boldSystemFont(ofSize: 18)
//        taskBtn.frame.size = CGSize(width: 100, height: 25)
//        taskBtn.layer.cornerRadius = 10
//        taskBtn.addTarget(self, action: #selector(taskSelected), for: .touchUpInside)
//        let taskBarBtn = UIBarButtonItem(customView: taskBtn)
//        // add items into bar
//        bar.items = [flexible, eventBarBtn, flexible, taskBarBtn, flexible]
//        textView.inputAccessoryView = bar
//        // design textiew
//        textView.layer.cornerRadius = 10
//        textViewPlaceHolder.layer.cornerRadius = 10
//        // show keyboard
//        textView.becomeFirstResponder()
//        // add target that will hide keyboard when user touch view
//        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
//        view.addGestureRecognizer(tap)
//    }
//    
//    // MARK: - action when user select edit start and end time
//    @IBAction func pressedStartBtn(_ sender: Any) {
//        print("pressedStartBtn")
//        showDatePicker = true
//        dismissKeyboard()
//        editStartDatePicker = true
//        editEndDatePicker = false
//        tableView.reloadData()
//    }
//    
//    @IBAction func pressedEndBtn(_ sender: Any) {
//        print("pressedEndBtn")
//        showDatePicker = true
//        dismissKeyboard()
//        editEndDatePicker = true
//        editStartDatePicker = false
//        tableView.reloadData()
//    }
//    
//    @objc func switchChanged(_ sender : UISwitch!){
//        print("The switch is \(sender.isOn ? "ON" : "OFF")")
//        allDayCalendar = !allDayCalendar
//        tableView.reloadData()
//    }
//    
//    @IBAction func selectedDatePicker(_ sender: Any) {
//        print("selectedDatePicker")
//    }
//    
//    
//    
//    // MARK: - TableView DataSource Method
//    // func to specify the number of the prototype cell
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//    
//    // case show the datePicker
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if(showDatePicker){
//            return 3
//        } else {
//            return 2
//        }
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "AllDayEventCell", for: indexPath)
//        
//        // All-day event cell will use in both show and not show datePicker
//        let allDaycell = tableView.dequeueReusableCell(withIdentifier: "AllDayEventCell", for: indexPath)
//        allDaycell.textLabel?.text = "All-day event"
//        allDaycell.textLabel?.font = .systemFont(ofSize: 16)
//        // add switch to cell
//        let switchView = UISwitch(frame: .zero)
//        switchView.setOn(false, animated: true)
//        // make switch on/off
//        if(allDayCalendar) {
//            switchView.setOn(true, animated: true)
//        }
//        // assign switchView onset color
//        switchView.onTintColor = UIColor(named: "AccentColor" )
//        switchView.tag = indexPath.row
//        switchView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
//        switchView.transform = CGAffineTransform(scaleX: 0.9, y: 0.8)
//        allDaycell.accessoryView = switchView
//        
//        
//        let startEndTimecell = tableView.dequeueReusableCell(withIdentifier: "StartEndTimeCell") as! CustomStartEndTimeCell
//        // to customize if all-day event is select or not select
//        if(allDayCalendar) {
//            startEndTimecell.timeStartLabel.isHidden = true
//            startEndTimecell.timeEndLabel.isHidden = true
//        } else {
//            startEndTimecell.timeStartLabel.isHidden = false
//            startEndTimecell.timeEndLabel.isHidden = false
//        }
//        
//        
//        // show datePicker
//        if(showDatePicker){
//            // cell to select start and end time
//            if(indexPath.row == 0){
//                // start - end time
//                if(editStartDatePicker) {
//                    startEndTimecell.stackStart.backgroundColor = UIColor(named: "AccentColor")
//                    startEndTimecell.stackEnd.backgroundColor = UIColor(named: "addEditAlarmBG")
//                    startEndTimecell.stackAll.backgroundColor = UIColor(named: "addEditAlarmBG")
//                }
//                
//                // user select to edit editEndDatePicker
//                if(editEndDatePicker) {
//                    startEndTimecell.stackEnd.layer.cornerRadius = -CGFloat(25)
//                    startEndTimecell.stackStart.clipsToBounds = true
//                    startEndTimecell.stackAll.backgroundColor = UIColor(named: "AccentColor")
//                    startEndTimecell.stackStart.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
//                    startEndTimecell.stackEnd.backgroundColor = UIColor(named: "AccentColor")
//                    startEndTimecell.stackStart.backgroundColor = UIColor(named: "addEditAlarmBG")
//                }
//                // specify row height
//                tableView.rowHeight = 60
//                return startEndTimecell
//            }
//            
//            // datePicker
//            if (indexPath.row == 1){
//                let cell = tableView.dequeueReusableCell(withIdentifier: "DateTimePickerCell", for: indexPath)
//                tableView.rowHeight = 175
//                return cell
//            }
//            
//            // All-day event
//            if (indexPath.row == 2){
//                tableView.rowHeight = 60
//                return allDaycell
//            }
//        }
//        
//        // not show datePicker
//        if(!showDatePicker) {
//            // start - end time
//            if(indexPath.row == 0){
//                if(!editStartDatePicker) && (!editEndDatePicker) {
//                    startEndTimecell.stackStart.layer.cornerRadius = CGFloat(25)
//                    startEndTimecell.stackStart.clipsToBounds = true
//                    startEndTimecell.stackStart.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
//                    startEndTimecell.stackStart.backgroundColor = UIColor(named: "lightGrey")
//                    startEndTimecell.stackEnd.backgroundColor = UIColor(named: "addEditAlarmBG")
//                    startEndTimecell.stackAll.backgroundColor = UIColor(named: "addEditAlarmBG")
//                }
//                tableView.rowHeight = 60
//                return startEndTimecell
//            }
//            
//            // All-day event
//            if (indexPath.row == 1){
//                tableView.rowHeight = 60
//                return allDaycell
//            }
//        }
//        
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("selectrow: \(indexPath.row)")
//        dismissKeyboard()
//    }
//    
//    // MARK: - Create UIToolbar that will attach to top of keyboard
//    @objc func eventSelected(){
//        print("eventSelected")
//        // select eventBtn
//        eventBtn.layer.backgroundColor = UIColor(named: "AccentColor")?.cgColor
//        eventBtn.tintColor = .white
//        eventBtn.setTitleColor(.white, for: .normal)
//        eventBtn.isSelected = true
//        // deselect taskBtn
//        taskBtn.layer.backgroundColor = UIColor(named: "Default")?.cgColor
//        taskBtn.tintColor = UIColor(named: "AccentColor")
//        taskBtn.setTitleColor(UIColor(named: "AccentColor"), for: .normal)
//        taskBtn.isSelected = false
//    }
//    
//    @objc func taskSelected(_ sender: UIButton){
//        print("taskSelected")
//        // select taskBtn
//        taskBtn.layer.backgroundColor = UIColor(named: "AccentColor")?.cgColor
//        taskBtn.tintColor = .white
//        taskBtn.setTitleColor(.white, for: .normal)
//        taskBtn.isSelected = true
//        // deselect eventBtn
//        eventBtn.layer.backgroundColor = UIColor(named: "Default")?.cgColor
//        eventBtn.tintColor = UIColor(named: "AccentColor")
//        eventBtn.setTitleColor(UIColor(named: "AccentColor"), for: .normal)
//        eventBtn.isSelected = false
//    }
//    
//    // MARK: - textView
//    func textViewDidChange(_ textView: UITextView) {
//        print("textViewDidChange")
//        textViewPlaceHolder.text = ""
//        textView.sizeToFit()
//        textView.isScrollEnabled = false
//        if(textView.text == ""){
//            textViewPlaceHolder.text = "Add title"
//        }
//    }
//    
//    // will call when user click textView
//    func textViewDidBeginEditing(_ textView: UITextView) {
//        print("textViewDidBeginEditing")
//        showDatePicker = false
//        editStartDatePicker = false
//        editEndDatePicker = false
//        tableView.reloadData()
//    }
//    
//    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
//        print("textViewShouldBeginEditing")
//        return true
//    }
//    
//    // clear what user type
//    @IBAction func pressedClearTyping(_ sender: Any) {
//        textView.text = ""
//        textViewPlaceHolder.text = "Hello"
//        textView.sizeToFit()
//        textView.isScrollEnabled = false
//    }
//    
//    // Calls this function when the tap is recognized.
//    @objc func dismissKeyboard() {
//        //Causes the view (or one of its embedded text fields) to resign the first responder status.
//        view.endEditing(true)
//    }
//}

//    // MARK: - side menu
//    func showMenuController(showExpanded: Bool){
//
//        // show menu
//        if showExpanded {
//
//            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
//                //self.navigationController?.isNavigationBarHidden = true
//                //self.tabBarController?.tabBar.isHidden = true
//                self.weekView.frame.origin.y = self.view.frame.height
//
//            },completion: nil)
//
//
//        }
//        // hide menu
//        else {
//            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
//
////                self.navigationController?.isNavigationBarHidden = false
////                self.tabBarController?.tabBar.isHidden = false
//                self.weekView.frame.origin.y = 0
//
//            },completion: nil)
//        }
//    }
//
//    func handleMenuToggle() {
//        isExpanded = !isExpanded
//        showMenuController(showExpanded: isExpanded)
//    }
