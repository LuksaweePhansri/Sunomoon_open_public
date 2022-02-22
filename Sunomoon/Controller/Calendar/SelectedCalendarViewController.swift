//
//  SelectedCalendarViewController.swift
//  Sunomoon
//
//  Created by Luksawee Phansri on 8/7/21.
//
import Foundation
import UIKit
import EventKit
import EventKitUI
import Contacts
import MapKit

// MARK: - Struct that will use to render attendee
class MyPlacemark: CLPlacemark {}
// struct to record the invitation status
struct AttendeesStatusList {
    var email: String?
    var status: Int?
}

class SelectedCalendarViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate{
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var delBtn: UIButton!
    @IBOutlet weak var bgView: UIView!
    
    // load data from eventkit
    var calendarData = CalendarData()
    let eventStore = EKEventStore()
    var eventIdentifier: String?
    var ekEvent: EKEvent?
    var hasAttendees: Bool?
    var participantStatus: Int?
    var totalSection: Int = 1
    var showregInfoCalendarCell: Bool = true
    var showActionInvitionCell: Bool = false
    var showLocationCalndarCell: Bool = false
    var showAlertCalendarCell: Bool = false
    var showNumberOfAttendees: Bool = false
    var showAttendeeInfoCell: Bool = false
    var showNoteCalendarCell: Bool = false
    var showEditDelCalendarCell: Bool = true
    var showURLCalendarCell: Bool = false
    var showZoomLinkCalendarCell: Bool = false        // NEED TO UPDATE LATER
    var urlRow: Int = -1
    var locationRow: Int = -1

    fileprivate let gregorian: NSCalendar! = NSCalendar(calendarIdentifier:NSCalendar.Identifier.gregorian)
    
    // tableView
    var defaultHeight: CGFloat = 130
    var tableViewHeight: CGFloat = 130
    var regInfoCellHeight: CGFloat = 130
    var originLabelHeight: CGFloat = 21.6
    var labelHeight: CGFloat = 45   // use 4 since the section that will rednder Edit and Del Btn has size 45
    var rowInSection1: Int = 0
    var cellInSection1: [String] = []
    var noteTextViewHeight: CGFloat = 0
    var urlTextViewHeight: CGFloat = 0
    var locationTextViewHeight: CGFloat = 0
    var guide: UILayoutGuide?
    var remainViewToshowTableView: CGFloat?
    var cellConstant: CGFloat = 10
    var numberOfAttendees: Int?
    var alertList: [TimeInterval] = []
    var attendeesStatusList: [AttendeesStatusList] = []
    var invitationStatus: Int = 0
    let contactManager = CNContactStore()
    override func viewDidLoad() {
        print("viewdidload")
        // set light mode only
        overrideUserInterfaceStyle = .light
        // lock screen
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        super.viewDidLoad()
        setComponents()
        //openAppleMapForPlace()
        print(ekEvent?.attendees)
        //openGoogleMapForPlace()
    }
    
    
    
    // this will use to add attendee in new event
    func yo(){
        let a = eventStore.event(withIdentifier: ekEvent!.calendarItemIdentifier)
        let predicate = eventStore.predicateForEvents(withStart: ekEvent!.startDate, end: ekEvent!.endDate, calendars: nil)
        let eventsKitEvents = eventStore.events(matching: predicate)
        let events = eventsKitEvents.map { curEkEvent in
            if(curEkEvent.calendarItemIdentifier == ekEvent!.calendarItemIdentifier){
                var attendees = [EKParticipant]()
                var count = curEkEvent.attendees?.count
                let status = 2
                if(count ?? 0 > 0){
                    attendees = curEkEvent.attendees!
                    for i in 0 ..< count!{
                        attendees[i].setValue(status, forKey: "participantStatus")
                    }
                }
                curEkEvent.setValue(attendees, forKey: "attendees")
                print(attendees[0].url)
                switch (EKEventStore.authorizationStatus(for: .event)){
                case .authorized:
                    do {
                        print("save")
                        try self.eventStore.save(curEkEvent, span: .thisEvent)
                        
                    } catch let e as NSError{
                        print("error!!! \(e)")
                    }
                @unknown default:
                    print("default")
                }
            }
        }
    }
    
    private func createParticipant(email email: String) -> EKParticipant? {
        let customClass: AnyClass? = NSClassFromString("EKAttendee")
        if let type = customClass as? NSObject.Type {
            let attendee = type.init()
            attendee.setValue(email, forKey: "emailAddress")
            return attendee as? EKParticipant
        }
        return nil
    }
    
    // this will use to add attendee
    func yo1(){
        var a = eventStore.event(withIdentifier: ekEvent!.eventIdentifier)
        print(a?.organizer)
        let predicate = eventStore.predicateForEvents(withStart: ekEvent!.startDate, end: ekEvent!.endDate, calendars: nil)
        let eventsKitEvents = eventStore.events(matching: predicate)
        let events = eventsKitEvents.map { curEkEvent in
            if(curEkEvent.calendarItemIdentifier == ekEvent!.calendarItemIdentifier){
                a = curEkEvent
                var attendees = [EKParticipant]()
                var count = curEkEvent.attendees?.count
                let status = 2
                if(count ?? 0 > 0){
                    attendees = curEkEvent.attendees!
                    for i in 0 ..< count!{
                        attendees[i].setValue(status, forKey: "participantStatus")
                    }
                }
                a!.setValue(attendees, forKey: "attendees")
                switch (EKEventStore.authorizationStatus(for: .event)){
                case .authorized:
                    
                    do {
                        try self.eventStore.save(a!, span: .thisEvent)
                        
                    } catch let e as NSError{
                        print("error!!! \(e)")
                    }
                @unknown default:
                    print("default")
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // lock screen
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        tableView.reloadData()
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("bye")
    }
    
    // MARK: - Func that will react when user press button
    // func that will perform segue selectedEditCalendarSegue that will goBackToCalendarViewController
    @objc func goBackToCalendarViewController() {
        print("goBackToCalendarViewController")
        tapBtn()
        dismiss(animated: false, completion: nil)
    }
    
    // user press edit
    @IBAction func pressEditBtn(_ sender: Any) {
        tapBtn()
        performSegue(withIdentifier: "goToAddEditEventTaskSegue", sender: self)
    }
    
    // user press delete
    @IBAction func pressDelBtn(_ sender: Any) {
        performSegue(withIdentifier: "goToSelectedDelCalendarSegue", sender: self)
    }
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "goToSelectedDelCalendarSegue"){
            let destinationVC = segue.destination as! ConfirmDeleteCalendarViewController
            destinationVC.ekEvent = ekEvent!
            destinationVC.eventIdentifier = eventIdentifier!
            destinationVC.hasAttendees = hasAttendees
            destinationVC.participantStatus = participantStatus
            //destinationVC.viewWillAppear(true)
        }
        if(segue.identifier == "goToAddEditEventTaskSegue"){
            let destinationVC = segue.destination as! UINavigationController
            let addEditEventTaskVC = destinationVC.topViewController as! AddEditEventTaskViewController
            addEditEventTaskVC.isEditingMode = true
            addEditEventTaskVC.eventIdentifier = eventIdentifier!
            addEditEventTaskVC.ekEvent = ekEvent!
        }
        if(segue.identifier == "goToResponseInvitationSegue"){
            let destinationVC = segue.destination as! UpdateAttendeeStatusViewController
            if(eventIdentifier != nil){
                destinationVC.eventIdentifier = eventIdentifier
                destinationVC.ekEvent = ekEvent
                if(participantStatus != nil){
                    destinationVC.participantStatus = participantStatus
                }
            }
        }
        if(segue.identifier == "goToMapCalendarSegue"){
            
        }
    }
    
    // MARK: - tableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return totalSection
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRow: Int = 0
        if(section == 0){
            numberOfRow = 1
            // case user need to response to the invitation
            if(showActionInvitionCell){
                numberOfRow = 2
            }
        }
        else if(section == 1){
            numberOfRow = 0
            if(showLocationCalndarCell){
                numberOfRow += 1
            }
            if(showAlertCalendarCell){
                numberOfRow += ekEvent!.alarms!.count
            }
            if(showNumberOfAttendees){
                numberOfRow += 1
            }
            if(showAttendeeInfoCell){
                numberOfRow += numberOfAttendees!
            }
            if(showNoteCalendarCell){
                numberOfRow += 1
            }
            if(showURLCalendarCell){
                numberOfRow += 1
            }
        }
        return numberOfRow
    }
    
    // sprcific tableView height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 60
        if(indexPath.section == 0) {
            if(indexPath.row == 0) {
                height = regInfoCellHeight
            }
            if(indexPath.row == 1) {
                height = 55
            }
        }
        if(indexPath.section == 1) {
            if(showLocationCalndarCell){
                if(locationRow >= 0) && (indexPath.row == locationRow){
                    if(locationTextViewHeight > 50){
                        height = locationTextViewHeight + cellConstant
                    }
                }
            }
            if(showURLCalendarCell){
                if(urlRow >= 0) && (indexPath.row == urlRow){
                    if(urlTextViewHeight > 50){
                        height = urlTextViewHeight + cellConstant
                    }
                }
            }
            if(indexPath.row == (rowInSection1 - 1)) {
                if(showNoteCalendarCell){
                    if(noteTextViewHeight > 50){
                        height = noteTextViewHeight + cellConstant
                    }
                }
            }
        }
        return height
    }
    
    // render tableView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(ekEvent != nil){
            if(indexPath.section == 0){
                if(indexPath.row == 0){
                    let cell = tableView.dequeueReusableCell(withIdentifier: "RegInfoCalendarCell") as! RegInfoCalendarCell
                    // title
                    cell.title.text = ekEvent?.title
                    cell.title.sizeToFit()
                    var currentHeight = cell.title.bounds.size.height
                    
                    // start - end date
                    let startDate = ekEvent?.startDate
                    let endDate = ekEvent?.endDate
                    let diffComponents = Calendar.current.dateComponents([.hour, .minute], from: startDate!, to: endDate!)
                    let diffHour = diffComponents.hour
                    let dateFormatter = DateFormatter()
                    
                    // one day event
                    if(calendarData.isOneDayEvent(startDate: startDate!, endDate: endDate!)){
                        dateFormatter.dateFormat = "EEEE, MMM-dd"
                        var stringStartDate = dateFormatter.string(from: startDate!)
                        cell.startDate.text = stringStartDate
                        dateFormatter.dateFormat = "h:mm a"
                        stringStartDate = dateFormatter.string(from: startDate!)
                        let stringEndDate = dateFormatter.string(from: endDate!)
                        cell.time.text = "\(stringStartDate) - \(stringEndDate)"
                    }
                    // several day events
                    else {
                        dateFormatter.dateFormat = "EEEE, MMM-dd"
                        let stringStartDate = dateFormatter.string(from: startDate!)
                        cell.startDate.text = stringStartDate
                        cell.startDate.font = .boldSystemFont(ofSize: 15)
                        let stringEndDate = dateFormatter.string(from: endDate!)
                        cell.time.text = stringEndDate
                    }
                    // update cell height
                    regInfoCellHeight = regInfoCellHeight + currentHeight - originLabelHeight
                    tableViewHeight = tableViewHeight + regInfoCellHeight - defaultHeight
                    updateViewConstraints()
                    
                    // account
                    cell.accountDetail.text = ekEvent?.calendar.title
                    // hide seperator
                    cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
                    return cell
                }
                // cell that will allow user to response to the invitation
                else if(indexPath.row == 1){
                    var cell = tableView.dequeueReusableCell(withIdentifier: "ActionInvitationCell") as! ActionInvitationCell
                    switch(invitationStatus){
                        //accept
                    case 2:
                        cell.responseBtn.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
                        cell.responseBtn.tintColor = UIColor(named: "lightGreen")
                        cell.responseBtn.setTitle("Accept", for: .normal)
                        // decline
                    case 3:
                        cell.responseBtn.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
                        cell.responseBtn.setTitle("Decline", for: .normal)
                        cell.responseBtn.tintColor = UIColor.red
                        // tentative
                    case 4:
                        cell.responseBtn.setTitle("Maybe", for: .normal)
                        // pending
                    default:
                        cell.responseBtn.setTitle("Response to invitation", for: .normal)
                    }
                    cell.responseBtn.layer.cornerRadius = 15
                    cell.responseBtn.layer.borderWidth = 1
                    cell.responseBtn.layer.borderColor = UIColor.lightGray.cgColor
                    // tabResponse will use to add necessary variable when user want to response to invitation
                    let tapResponse = CustomTapGestureReconizerForCalendar(target: self, action: #selector(responseToInvitation(sender:)))
                    tapResponse.eventIdentifier = eventIdentifier
                    tapResponse.ekEvent = ekEvent
                    if(participantStatus != nil){
                        tapResponse.participantStatus = participantStatus
                    }
                    cell.responseBtn.addGestureRecognizer(tapResponse)
                    // hide seperator
                    cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
                    return cell
                }
            }
        }
        if(indexPath.section == 1){
            if(indexPath.row < cellInSection1.count){
                let cell = getUITableViewCell(indentifier: cellInSection1[indexPath.row])
                return cell
            }
        }
        var cell = tableView.dequeueReusableCell(withIdentifier: "RegInfoCalendarCell", for: indexPath)
        if(indexPath.section == 0){
            self.tableView.separatorColor = UIColor.red
            // hide seperator
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
        }
        else {
            tableView.separatorStyle = .singleLine
            self.tableView.separatorColor = UIColor.black
        }
        return cell
    }
    

    // render tableView
    func getUITableViewCell(indentifier: String) -> UITableViewCell{
        let cell: UITableViewCell
        switch indentifier {
        case "LocationCalendarCell":
            let cell = tableView.dequeueReusableCell(withIdentifier: indentifier) as! LocationCalendarCell
            print(ekEvent?.structuredLocation?.geoLocation)
            cell.textView.text = ekEvent?.structuredLocation?.title
            cell.textView.sizeToFit()
            cell.textView.isScrollEnabled = false
            locationTextViewHeight = cell.textView.bounds.height
            if(locationTextViewHeight  > 50){
                tableViewHeight = tableViewHeight - 60 + locationTextViewHeight + cellConstant
                updateViewConstraints()
            }
            let tapOpenMap = CustomTapGestureReconizerToOpenMap(target: self, action: #selector(openMap(sender:)))
            tapOpenMap.ekEvent = ekEvent
            tapOpenMap.eventIdentifier = eventIdentifier
            tapOpenMap.textView = cell.textView
            cell.textView.addGestureRecognizer(tapOpenMap)
            return cell
        case "AlertCalendarCell":
            let cell = tableView.dequeueReusableCell(withIdentifier: indentifier) as! AlertCalendarCell
            var numberOfAlert = alertList.count
            if(numberOfAlert > 0){
                if(alertList[0] == -86400){
                    cell.label.text = "1 day before"
                } else if(alertList[0] == -3600){
                    cell.label.text = "1 hour before"
                } else if(alertList[0] == -60){
                    cell.label.text = "1 minute before"
                } else if(alertList[0] < -86400){
                    let alertTime = Int(alertList[0] / 86400 * (-1))
                    cell.label.text = "\(alertTime) days before"
                } else if(alertList[0] > -3600){
                    let alertTime = Int(alertList[0] / 60 * (-1))
                    cell.label.text = "\(alertTime) minutes before"
                } else if(alertList[0] > -86400){
                    let alertTime = Int(alertList[0] / 3600 * (-1))
                    cell.label.text = "\(alertTime) hours before"
                }
                alertList.removeFirst()
            }
            return cell
        case "URLCalendarCell":
            let cell = tableView.dequeueReusableCell(withIdentifier: indentifier) as! URLCalendarCell
            cell.textView.text = ekEvent?.url?.absoluteString
            cell.textView.sizeToFit()
            cell.textView.isScrollEnabled = false
            urlTextViewHeight = cell.textView.bounds.height
            if(urlTextViewHeight  > 50){
                tableViewHeight = tableViewHeight - 60 + urlTextViewHeight + cellConstant
                updateViewConstraints()
            }
            return cell
        case "NumberAttendeesCell":
            let cell = tableView.dequeueReusableCell(withIdentifier: indentifier) as! NumberAttendeesCell
            var numberOfAttendees = attendeesStatusList.count
            if(numberOfAttendees == 1){
                cell.label.text = "\(numberOfAttendees) attendee"
            }
            else if(numberOfAttendees > 1){
                cell.label.text = "\(numberOfAttendees) attendees"
            }
            return cell
        case "AttendeeInfoCell":
            let cell = tableView.dequeueReusableCell(withIdentifier: indentifier) as! AttendeeInfoCell
            var numberOfAttendees = attendeesStatusList.count
            if(numberOfAttendees > 0){
                // participantStatus status
                switch(attendeesStatusList[0].status){
                    //accept
                case 2:
                    cell.statusImg.image = UIImage(systemName: "checkmark.circle.fill")
                    cell.statusImg.tintColor = UIColor(named: "lightGreen")
                    // decline
                case 3:
                    cell.statusImg.image = UIImage(systemName: "xmark.circle.fill")
                    cell.statusImg.tintColor = UIColor.red
                    // tentative or pending
                case 4:
                    cell.statusImg.image = UIImage(systemName: "questionmark.circle.fill")
                    cell.statusImg.tintColor = UIColor(named: "lightPastelOrange")
                default:
                    cell.statusImg.image = UIImage(systemName: "questionmark.circle.fill")
                    cell.statusImg.tintColor = UIColor.gray
                }
                cell.attendeeLabel.text = attendeesStatusList[0].email
                attendeesStatusList.removeFirst()
            }
            return cell
        case "NoteCalendarCell":
            let cell = tableView.dequeueReusableCell(withIdentifier: indentifier) as! NoteCalendarCell
            cell.textView.text = ekEvent?.notes
            cell.textView.sizeToFit()
            cell.textView.isScrollEnabled = false
            noteTextViewHeight = cell.textView.bounds.height
            if(noteTextViewHeight  > 50){
                tableViewHeight = tableViewHeight - 60 + noteTextViewHeight + cellConstant
                updateViewConstraints()
            }
            return cell
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "RegInfoCalendarCell") as! RegInfoCalendarCell
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.black
        return view
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 2
    }
    
    // MARK: - update constraint that will help the tableView
    // use to update tableView constraint
    override func updateViewConstraints() {
        if(tableViewHeight <=  remainViewToshowTableView! ){
            tableHeightConstraint.constant = tableViewHeight
        }
        else {
            tableView.topAnchor.constraint(equalTo: guide!.topAnchor ).isActive = true
        }
        super.updateViewConstraints()
    }
    
    // MARK: - set component fuction
    func setComponents(){
        // add tap gesture to link to goBackToCalendarViewController when user touch screen
        let tap = UITapGestureRecognizer(target: self, action: #selector(goBackToCalendarViewController))
        bgView.addGestureRecognizer(tap)
        guide = self.view.safeAreaLayoutGuide
        remainViewToshowTableView = view.bounds.height - view.safeAreaLayoutGuide.layoutFrame.height - labelHeight
        perpareDetilsToShow(event: ekEvent!)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.layer.cornerRadius = 30
        tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        addSwipeRecognizer()
        if(ekEvent != nil){
            if(!ekEvent!.calendar.allowsContentModifications){
                editBtn.setTitleColor(UIColor.lightGray, for: .normal )
                editBtn.isEnabled = false
                delBtn.tintColor = UIColor.lightGray
                delBtn.isEnabled = false
            }
        }
    }
    
    // MARK: - load selected event from local calendar with identifier
    // load data from the eventstore
    func getSelectedEvent(eventIdentifier: String) -> EKEvent {
        let event = eventStore.event(withIdentifier: eventIdentifier)
        return event!
    }
    
    func perpareDetilsToShow(event: EKEvent){
        // status of event
        if(event.hasAttendees){
            if(participantStatus != nil) {
                var email = event.organizer?.url.absoluteString.replacingOccurrences(of: "mailto:", with: "")
                if(event.calendar.title != email) && (event.organizer != nil){
                    tableViewHeight += 55
                    showActionInvitionCell = true
                }
            }
        }
        // location
        if(event.location != nil){
            if(event.location != ""){
                rowInSection1 += 1
                locationRow = rowInSection1  - 1
                print("locationRow \(locationRow )")
                cellInSection1.append("LocationCalendarCell")
                tableViewHeight += 60
                showLocationCalndarCell = true
            }
        }
        // alarm
        if(event.alarms != nil) {
            rowInSection1 += event.alarms!.count
            for i in 0..<event.alarms!.count{
                cellInSection1.append("AlertCalendarCell")
                tableViewHeight += 60
                var trigger = ekEvent?.alarms![i].relativeOffset
                alertList.append(trigger!)
            }
            showAlertCalendarCell = true
        }
        // url
        if(event.url != nil){
            print(event.url)
            rowInSection1 += 1
            urlRow = rowInSection1 - 1
            cellInSection1.append("URLCalendarCell")
            tableViewHeight += 60
            showURLCalendarCell = true
        }
        // attendees
        if(event.hasAttendees){
            if(event.attendees != nil){
                cellInSection1.append("NumberAttendeesCell")
                rowInSection1 += 1
                var totalAttendeedInSystem = event.attendees?.count
                numberOfAttendees = 0
                showNumberOfAttendees = true
                showAttendeeInfoCell = true
                tableViewHeight += 60
                for i in 0..<totalAttendeedInSystem! {
                    var email = event.attendees![i].url.absoluteString.replacingOccurrences(of: "mailto:", with: "")
                    var status: Int = event.attendees![i].participantStatus.rawValue
                    // attendee
                    if(event.calendar.title != email){
                        tableViewHeight += 60
                        numberOfAttendees! += 1
                        rowInSection1 += 1
                        var attendeesStatus = AttendeesStatusList(email: email, status: status)
                        attendeesStatusList.append(attendeesStatus)
                        cellInSection1.append("AttendeeInfoCell")
                    }
                    if(event.calendar.title == email){
                        invitationStatus = status
                    }
                }
            }
        }
        // note
        if(event.hasNotes) {
            rowInSection1 += 1
            cellInSection1.append("NoteCalendarCell")
            showNoteCalendarCell = true
            tableViewHeight += 60
        }
        // check tableView will have 1 or 2 section
        if(tableViewHeight > defaultHeight){
            totalSection = 2
            tableViewHeight += 2
        }
    }
    
    // MARK: - Helper function
    // use that make user go back to mainpage when swipe tableView downword
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if(velocity.y < -0.0125){
            goBackToCalendarViewController()
        }
    }
    
    // create the swipeGestureReconizer that make user go back to the CalendarViewController
    func addSwipeRecognizer() {
        let directions: [UISwipeGestureRecognizer.Direction] = [.down, .up, .left, .right]
        for direction in directions {
            let gesture = UISwipeGestureRecognizer(target: self, action: #selector(goBackToCalendarViewController))
            gesture.direction = direction
            bgView.addGestureRecognizer(gesture)
        }
    }
    
    // use to make haptic when user click botton
    func tapBtn(){
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    // use to show selected calendar that will perform response to ivitatoion
    @objc func responseToInvitation(sender: CustomTapGestureReconizerForCalendar){
        tapBtn()
        if(sender.participantStatus != nil){
            participantStatus = sender.participantStatus!
        }
        eventIdentifier = sender.eventIdentifier
        ekEvent = sender.ekEvent
        performSegue(withIdentifier: "goToResponseInvitationSegue", sender: self)
    }
    
    @objc func openMap(sender: CustomTapGestureReconizerToOpenMap){
        tapBtn()
        eventIdentifier = sender.eventIdentifier
        ekEvent = sender.ekEvent
        sender.textView?.resignFirstResponder()
        if(checkLatLon()){
            if(isGoogleMapAvailable()){
                performSegue(withIdentifier: "goToMapCalendarSegue", sender: self)
            } else {
                openAppleMapForPlace()
            }
        } else {
                sender.textView?.tintColor = .white
                sender.textView?.isSelectable = true
                sender.textView?.becomeFirstResponder()
                sender.textView?.selectAll(self)
        }
        sender.cancelsTouchesInView = true
    }
    
    func checkLatLon() -> Bool{
        let latitude =  ekEvent?.structuredLocation?.geoLocation?.coordinate.latitude
        let longitude =  ekEvent?.structuredLocation?.geoLocation?.coordinate.longitude
        if(latitude != nil) && (longitude != nil) {
            return true
        }
        return false
    }
    
    // perform open appleMap
    func openAppleMapForPlace(){
        print(ekEvent)
        let latitude:CLLocationDegrees =  (ekEvent?.structuredLocation?.geoLocation?.coordinate.latitude)!
        let longitude:CLLocationDegrees =  (ekEvent?.structuredLocation?.geoLocation?.coordinate.longitude)!
        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = ekEvent?.structuredLocation?.title
        
        (mapItem.openInMaps(launchOptions: options))
            print("find applemap")
    }
    
    // perform open googleMap
    func openGoogleMapForPlace(){
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps-x-callback://")!)) {
            let directionsRequest = "comgooglemaps-x-callback://" +
            "?q=dessert&center=35.660888,139.73073" + "&x-success=sourceapp://?resume=true&x-source=AirApp"
            let directionsURL = URL(string: directionsRequest)!
            UIApplication.shared.open(directionsURL, options: [:], completionHandler: nil)
        } else {
            print("Can't use comgooglemaps://");
            
        }
    }
    
    // check is GoogleMap available on the device
    func isGoogleMapAvailable() -> Bool{
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps-x-callback://")!)) {
            return true
        } else {
            return false
        }
    }
}

