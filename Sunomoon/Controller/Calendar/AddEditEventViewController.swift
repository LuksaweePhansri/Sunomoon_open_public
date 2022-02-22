//
//  AddEditEventTaskViewController.swift
//  Sunomoon
//
//  Created by Luksawee Phansri on 1/6/22.
//
import Foundation
import UIKit
import EventKit

class AddEditEventViewController:
    UITableViewController, UITextViewDelegate, UITabBarControllerDelegate  {
    @IBOutlet weak var textViewPlaceHolder: UITextView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var stackAll: UIStackView!
    @IBOutlet weak var stackStart: UIStackView!
    @IBOutlet weak var stackEnd: UIStackView!
    @IBOutlet weak var dateStartLabel: UILabel!
    @IBOutlet weak var timeStartLabel: UILabel!
    @IBOutlet weak var dateEndLabel: UILabel!
    @IBOutlet weak var timeEndLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var swichAllDay: UISwitch!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var stackBtn: UIImageView!
    @IBOutlet weak var showDetailsBtn: UIButton!
    @IBOutlet weak var attendeesCountLabel: UILabel!
    @IBOutlet weak var locationBtn: UIButton!
    
    // Mode
    // Section of component in the tableView
    // 0- Title
    // 1- date and date picker
    // 2- show detail
    // 3- account
    // 4- alert, repeat
    // 5- location, atttendees, vedio call, note
    var numberOfSection = 6
    var showDatePicker: Bool = false
    var editStartDatePicker: Bool = false
    var editEndDatePicker: Bool = false
    var allDayCalendar: Bool = false
    var showDetail: Bool = false
    
    // Editing mode
    var isEditingMode: Bool = false
    var calendarData = CalendarData()
    let eventStore = EKEventStore()
    var eventIdentifier: String?
    var ekEvent: EKEvent?
    
    fileprivate let gregorian: NSCalendar! = NSCalendar(calendarIdentifier:NSCalendar.Identifier.gregorian)
    
    // MARK: - View
    override func viewDidLoad() {
        // make app to have light theme
        overrideUserInterfaceStyle = .light
        // lock screen
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        super.viewDidLoad()
        textView.delegate = self
        setBackgroundComponents()
        setStartEndTimeStack()
        if(isEditingMode){
            title = "Edit"
            print(ekEvent)
        }
        else {
            title = "Add Event"
        }
        
        attendeesCountLabel.layer.cornerRadius = attendeesCountLabel.layer.bounds.width/2
        attendeesCountLabel.layer.backgroundColor = UIColor.yellow.cgColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // lock screen
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        print("viewWillAppear")
        print(UITableView.automaticDimension)
        
        tableView.reloadData()
    }
    
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if (item.title == "Location") {
            print("Location")
            UITabBar.appearance().isTranslucent = false
            tabBar.barTintColor = UIColor(named: "nightColor")
            tabBar.tintColor = UIColor(named: "AccentColor")
        }
    }
    
    // MARK: - action when user select edit start and end time
    @IBAction func selectedDateTime(_ sender: Any) {
    }
    
    // user select to edit start time for event/task
    @IBAction func pressedStartBtn(_ sender: Any) {
        print("pressedStartBtn")
        dismissKeyboard()
        showDatePicker = true
        editStartDatePicker = true
        editEndDatePicker = false
        setStartEndTimeStack()
        tableView.reloadData()
    }
    
    // user select to edit end time for event/task
    @IBAction func pressedEndBtn(_ sender: Any) {
        print("pressedEndBtn")
        dismissKeyboard()
        showDatePicker = true
        editEndDatePicker = true
        editStartDatePicker = false
        setStartEndTimeStack()
        tableView.reloadData()
    }
    
    // select all-day event
    @IBAction func slidedSwitchAllDay(_ sender: Any) {
        allDayCalendar = !allDayCalendar
        setStartEndTimeStack()
        showDatePicker = true
        tableView.reloadData()
    }
    
    // clear what user type
    @IBAction func pressedClearTyping(_ sender: Any) {
        textView.text = ""
        textViewPlaceHolder.text = "Title"
        textView.sizeToFit()
        textView.isScrollEnabled = false
        // update tableview
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }
    
    @IBAction func pressedLocationBtn(_ sender: Any) {
        locationBtn.tintColor = .red
        
    }
    
    @IBAction func pressedAttendeesBtn(_ sender: Any) {
    }
    
    @IBAction func pressedVideoCallBtn(_ sender: Any) {
    }
    
    @IBAction func pressedNoteBtn(_ sender: Any) {
    }
    
    @IBAction func pressedShowDetailsBtn(_ sender: Any) {
        showDetail = !showDetail
        print("showDetail")
        dismissKeyboard()
        tableView.reloadData()
    }
    
    @IBAction func pressedAccount(_ sender: Any) {
        print("pressedAccount")
        dismissKeyboard()
        showDatePicker = false
        tableView.reloadData()
    }
    
    @IBAction func pressedAlertTime(_ sender: Any) {
        dismissKeyboard()
        print("pressedAlertTime")
        showDatePicker = false
        tableView.reloadData()
    }
    
    @IBAction func pressedEditRepeat(_ sender: Any) {
        dismissKeyboard()
        print("pressedEditRepeat")
        showDatePicker = false
        tableView.reloadData()
    }
    
    @IBAction func pressedCancelBtn(_ sender: Any) {
        performSegue(withIdentifier: "goBackToCalendarVC", sender: self)
    }
    
    
    @IBAction func pressedSaveBtn(_ sender: Any) {
    }
    
    // MARK: - Create UIToolbar that will attach to top of keyboard
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat
        height = 55
        if(indexPath.section == 0){
            height = UITableView.automaticDimension
        }
        
        if(indexPath.section == 1) {
            if(indexPath.row == 0){
                height = 70
            }
            if(indexPath.row == 1){
                if(showDatePicker) {
                    height = 175
                }
                else {
                    height = 0
                }
            }
        }
        
        if(indexPath.section == 5){
            height = 50
        }
        
        if(!showDetail) {
            if(indexPath.section >= 3){
                height = 0
            }
        }
        
        if(showDetail) {
            if(indexPath.section == 2){
                height = 0
            }
        }
        
        if(isEditingMode){
            if(indexPath.section == 7){
                height = 60
            }
        }
        return height
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var string: String = ""
        if(section == 2){
            string = " "
        }
        return string
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        print("numberOfSections")
        return numberOfSection
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    // MARK: - textView
    func textViewDidChange(_ textView: UITextView) {
        print("textViewDidChange")
        textViewPlaceHolder.text = ""
        textView.sizeToFit()
        textView.isScrollEnabled = false
        if(textView.text == ""){
            textViewPlaceHolder.text = "Add title"
        }
        // update tableview
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }
    
    // will call when user click textView
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("textViewDidBeginEditing")
        showDatePicker = false
        editStartDatePicker = false
        editEndDatePicker = false
        setStartEndTimeStack()
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        print("textViewShouldBeginEditing")
        return true
    }
    
    // Calls this function when the tap is recognized
    // will dismiss keyboard and datePicker
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
        showDatePicker = false
        tableView.reloadData()
    }
    
    // MARK: - set components
    func setBackgroundComponents() {
        // style show details btn
        showDetailsBtn.layer.cornerRadius = 15
        // make toLabel with green circle
        toLabel.layer.cornerRadius = toLabel.bounds.width/2
        toLabel.layer.backgroundColor = UIColor(named: "lightGreen")?.cgColor
        // design textiew
        textView.layer.cornerRadius = 10
        textViewPlaceHolder.layer.cornerRadius = 10
        // show keyboard
        textView.becomeFirstResponder()
        // add target that will hide keyboard and datePicker when user touch view
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        // add target that will hide keyboard and datePicker when user slide screen
        addSwipeRecognizer()
        // style datePicker
        datePicker.backgroundColor = .white
        self.datePicker.layer.cornerRadius = 25
        self.datePicker.layer.masksToBounds = true
        // style switch
        swichAllDay.transform = CGAffineTransform(scaleX: 0.9, y: 0.8)
        //swichAllDay.transform = CGAffineTransform(scaleX: 1.0, y: 0.9)
        swichAllDay.onTintColor = UIColor(named: "AccentColor" )
        // style stackBtn
        stackBtn.layer.cornerRadius = 10
        stackBtn.layer.backgroundColor = UIColor(named: "lightestPastelBlue")?.cgColor
    }
    
    // create the swipeGestureReconizer for all directions
    func addSwipeRecognizer() {
        let directions: [UISwipeGestureRecognizer.Direction] = [.right, .left, .up, .down]
        for direction in directions {
            let gesture = UISwipeGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
            gesture.direction = direction
            view.addGestureRecognizer(gesture)
        }
    }
    
    // syle start-end time
    func setStartEndTimeStack() {
        // set font color
        dateStartLabel.textColor = .black
        timeStartLabel.textColor = .black
        dateEndLabel.textColor = .black
        timeEndLabel.textColor = .black
        if(!editStartDatePicker) && (!editEndDatePicker) {
            // round one side of stackStart
            //            stackStart.layer.cornerRadius = CGFloat(25)
            //            stackStart.clipsToBounds = true
            //            stackStart.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
            stackStart.backgroundColor = UIColor(named: "lightGrey")
            stackEnd.backgroundColor = UIColor(named: "addEditAlarmBG")
        }
        // start - end time
        else if(editStartDatePicker) {
            stackStart.backgroundColor = UIColor(named: "AccentColor")
            stackEnd.backgroundColor = UIColor(named: "addEditAlarmBG")
            dateStartLabel.textColor = .white
            timeStartLabel.textColor = .white
        }
        // user select to edit editEndDatePicker
        else if(editEndDatePicker) {
            stackStart.backgroundColor = UIColor(named: "addEditAlarmBG")
            stackEnd.backgroundColor = UIColor(named: "AccentColor")
            dateEndLabel.textColor = .white
            timeEndLabel.textColor = .white
        }
        // user select all day event
        if(allDayCalendar) {
            timeStartLabel.isHidden = true
            timeEndLabel.isHidden = true
            dateStartLabel.font = .systemFont(ofSize: 18, weight: .semibold)
            dateEndLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        } else {
            timeStartLabel.isHidden = false
            timeEndLabel.isHidden = false
            dateStartLabel.font = .systemFont(ofSize: 15, weight: .regular)
            dateEndLabel.font = .systemFont(ofSize: 15, weight: .regular)
        }
    }
}

