//
//  ConfirmDeleteCalendarViewController.swift
//  Sunomoon
//
//  Created by Luksawee Phansri on 1/10/22.
//

import Foundation
import UIKit
import EventKit
import MessageUI

class ConfirmDeleteCalendarViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bgView: UIView!
    
    // load data from eventkit or prev scene
    var calendarData = CalendarData()
    let eventStore = EKEventStore()
    var eventIdentifier: String?
    var ekEvent: EKEvent?
    var hasAttendees: Bool?
    var participantStatus: Int?
    
    // tableView
    var defaultHeight: CGFloat = 130
    var tableViewHeight: CGFloat = 1
    var guide: UILayoutGuide?
    var remainViewToshowTableView: CGFloat?
    var recurrence: Bool = false
    var regInfoDelCellHeight: CGFloat = 125
    var singleCalendarDelCellHeight: CGFloat = 160
    var multipleCalendarDelCellHeight: CGFloat = 300
    var sendCancellationCellHeight: CGFloat = 245
    // Delete mode
    // 0 - not specify
    // 1 - only 1 event or delete single evnet
    // 2 - All Future
    // 3 - All
    var delMode: Int = 0
    var needToSendCancellation: Bool = false
    var sendCancellationStep: Bool = false
    
    // MARK: - View
    override func viewDidLoad() {
        print("ConfirmDeleteCalendarViewController")
        // make app to have light theme
        overrideUserInterfaceStyle = .light
        // lock screen
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        guide = self.view.safeAreaLayoutGuide
        remainViewToshowTableView = view.bounds.height - view.safeAreaLayoutGuide.layoutFrame.height
        if(ekEvent != nil){
            perpareDetilsToShow(event: ekEvent!)
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(goBackToCalendarViewController))
        bgView.addGestureRecognizer(tap)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.cornerRadius = 30
        tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - TableView
    // Number of row
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // case not the step of getting confirm to send invitation cancellation
        if(!sendCancellationStep){
            return 2
        } else {
            return 1
        }
    }
    
    // tableView height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 125
        if(!sendCancellationStep){
            if(indexPath.row == 0){
                height =  regInfoDelCellHeight
            }
            if(indexPath.row == 1){
                if(!recurrence){
                    height =  singleCalendarDelCellHeight
                } else {
                    height =  multipleCalendarDelCellHeight
                }
            }
        } else {
            height = sendCancellationCellHeight
        }
        return height
    }
    
    // render tableView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // TabGesture that will link to cancelBtn
        let tapCancel = UITapGestureRecognizer(target: self, action: #selector(goBackToCalendarViewController))
        // no need the step of getting confirm to send invitation cancellation
        if(!sendCancellationStep){
            if(indexPath.row == 0){
                // cell You're deleting an event
                let cell = tableView.dequeueReusableCell(withIdentifier: "RegInfoDelCell") as! RegInfoDelCell
                // if the event is the recurrence, it will tell user that it is the recurrence event
                // if the event is single event, it will show the title of event
                if(!recurrence){
                    cell.customLabel.text = ekEvent!.title
                }
                cell.customLabel.sizeToFit()
                // calculate cell height
                regInfoDelCellHeight = cell.remindDelLabel.fs_height + cell.customLabel.fs_height + 50
                // assign tableViewHeight
                tableViewHeight += regInfoDelCellHeight
                updateViewConstraints()
                return cell
            } else if(indexPath.row == 1){
                // no need the step of getting confirm to send invitation cancellation
                if(!recurrence){
                    // cell that will show button that allow user to select action
                    let cell = tableView.dequeueReusableCell(withIdentifier: "SingleCalendarDelCell") as! SingleCalendarDelCell
                    tableViewHeight += singleCalendarDelCellHeight
                    updateViewConstraints()
                    // initail tabDel TapGesture that will perform delete event when user select delete
                    let tapDel = CustomTapGestureReconizerForCalendar(target: self, action: #selector(pressedDelBtn(sender: )))
                    tapDel.title = cell.deleteBtn.titleLabel?.text
                    cell.deleteBtn.addGestureRecognizer(tapDel)
                    cell.cancelBtn.addGestureRecognizer(tapCancel)
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "MultipleCalendarDelCell") as! MultipleCalendarDelCell
                    tableViewHeight += multipleCalendarDelCellHeight
                    updateViewConstraints()
                    // tapDelAll will use to perform  delete ALL event
                    let tapDelAll = CustomTapGestureReconizerForCalendar(target: self, action: #selector(pressedDelBtn(sender: )))
                    tapDelAll.title = cell.allBtn.titleLabel?.text
                    cell.allBtn.addGestureRecognizer(tapDelAll)
                    // tapDelOnlyThisEvent will use to perform  delete Only This Event event
                    let tapDelOnlyThisEvent = CustomTapGestureReconizerForCalendar(target: self, action: #selector(pressedDelBtn(sender: )))
                    tapDelOnlyThisEvent.title = cell.onlyThisEventBtn.titleLabel?.text
                    cell.onlyThisEventBtn.addGestureRecognizer(tapDelOnlyThisEvent)
                    // tapDelAllFutue will use to perform  delete All Future
                    let tapDelAllFutue = CustomTapGestureReconizerForCalendar(target: self, action: #selector(pressedDelBtn(sender: )))
                    tapDelAllFutue.title = cell.allFutureBtn.titleLabel?.text
                    cell.allFutureBtn.addGestureRecognizer(tapDelAllFutue)
                    cell.cancelBtn.addGestureRecognizer(tapCancel)
                    return cell
                }
            }
        }
        // send cancellation step
        if(sendCancellationStep){
            let cell = tableView.dequeueReusableCell(withIdentifier: "SendCancellationCell") as! SendCancellationCell
            tableViewHeight = sendCancellationCellHeight
            updateViewConstraints()
            let tabSend = UITapGestureRecognizer(target: self, action: #selector(sendCancellationAndDelete))
            cell.sendBtn.addGestureRecognizer(tabSend)
            cell.cancelBtn.addGestureRecognizer(tapCancel)
            return cell
        }
        // this cell should not be render
        // it will use only if an unexpected case happend
        let cell = tableView.dequeueReusableCell(withIdentifier: "RegInfoDelCell")
        return cell!
    }
    
    // func to prepare to delete event
    // if event need to send invitation cancellation, show sendCancelation view and wait till user confirm an action
    // if event does not need to send invitation cancellation, delete event that user select
    @objc func pressedDelBtn(sender: CustomTapGestureReconizerForCalendar){
        if((sender.title != nil) && (eventIdentifier != nil) && (ekEvent != nil)){
            switch(sender.title){
            case "Delete":
                // case an event need to send cancellation
                if(needToSendCancellation){
                    // specify that user want to delete one/single event
                    delMode = 1
                    goToSendCancellationStep()
                } else {
                    performDelOneEvent(eventIdentifier: eventIdentifier!)
                    performSegue(withIdentifier: "goBackToCalendarVC", sender: self)
                }
            case "All":
                // case need to send cancellation
                if(needToSendCancellation){
                    // specify that user want to delete ALL event
                    delMode = 3
                    goToSendCancellationStep()
                } else {
                    performDelAllEvent(eventIdentifier: eventIdentifier!)
                    performSegue(withIdentifier: "goBackToCalendarVC", sender: self)
                }
            case "Only This Event":
                // case need to send cancellation
                if(needToSendCancellation){
                    // specify that user want to delete Only This Event event
                    delMode = 1
                    goToSendCancellationStep()
                } else {
                    performDelOntyThisEvent(ekEvent: ekEvent!)
                    performSegue(withIdentifier: "goBackToCalendarVC", sender: self)
                }
            case "All Future":
                print("All Future")
                // case need to send cancellation
                if(needToSendCancellation){
                    // specify that user want to delete Only This Event event
                    delMode = 2
                    goToSendCancellationStep()
                } else {
                    performDelAllFutreEvent(ekEvent: ekEvent!, eventIdentifier: eventIdentifier!)
                    performSegue(withIdentifier: "goBackToCalendarVC", sender: self)
                }
            default:
                print("Something goes wrong!!")
            }
        }
    }
    
    // func that make the view reload and go to send ivitaion cancellation step
    func goToSendCancellationStep(){
        sendCancellationStep = true
        tableView.reloadData()
    }
    
    @objc func sendCancellationAndDelete(){
        if((eventIdentifier != nil) && (ekEvent != nil)){
            if let delEvent = self.eventStore.event(withIdentifier: eventIdentifier!){
                // delete All
                if(delMode == 3){
                    performDelAllEvent(eventIdentifier: eventIdentifier!)
                }
                // delete All Future
                if(delMode == 2){
                    performDelAllFutreEvent(ekEvent: ekEvent!, eventIdentifier: eventIdentifier!)
                }
                if(delMode == 1){
                    if(recurrence){
                        performDelOntyThisEvent(ekEvent: ekEvent!)
                    } else {
                        performDelOneEvent(eventIdentifier: eventIdentifier!)
                    }
                }
            }
        }
        performSegue(withIdentifier: "goBackToCalendarVC", sender: self)
    }
    
    //MARK: - Perform delete event
    // perofrm delete one event that is not recurrence
    func performDelOneEvent(eventIdentifier: String){
        if let delEvent = self.eventStore.event(withIdentifier: eventIdentifier){
            do{
                try self.eventStore.remove(delEvent, span: .thisEvent, commit: true)
            } catch let e as NSError{
                print("error \(e)")
            }
        }
    }
    
    // perform delete ALL event
    func performDelAllEvent(eventIdentifier: String){
        if let delEvent = self.eventStore.event(withIdentifier: eventIdentifier){
            do{
                try self.eventStore.remove(delEvent, span: .futureEvents, commit: true)
            } catch let e as NSError{
                print("error \(e)")
            }
        }
    }
    
    // perform to delete Onty This Event in recurrence event
    // This func need to use ekEvent to access calendarItemIdentifier that will provide unique ID to remove specific event
    func performDelOntyThisEvent(ekEvent: EKEvent){
        let predicate = eventStore.predicateForEvents(withStart: ekEvent.startDate, end: ekEvent.endDate, calendars: nil)
        let eventsKitEvents = eventStore.events(matching: predicate)
        let events = eventsKitEvents.map { curEkEvent in
            if(curEkEvent.calendarItemIdentifier == ekEvent.calendarItemIdentifier){
                do {
                    try self.eventStore.remove(curEkEvent, span: .thisEvent, commit: true)
                } catch let e as NSError{
                    print("error \(e)")
                }
            }
        }
    }
    
    // perform to delete All Future in recurrence event
    // This func need to use ekEvent to access calendarItemIdentifier that will provide unique ID to remove specific event
    func performDelAllFutreEvent(ekEvent: EKEvent, eventIdentifier: String){
        print("performDelAllFutreEvent")
        print(ekEvent.calendarItemIdentifier)
        // newEndDate will not include current event so the endDate should less than current event startDate
        var newEndDate: Date = ekEvent.startDate
        var selectedFirstEvent: Bool = true
        // get the first event of the recurrence event
        if let firstRecurrenceEvent = eventStore.event(withIdentifier: eventIdentifier){
            // find the all event that match from first event date to end of selected current date
            let predicate = eventStore.predicateForEvents(withStart: firstRecurrenceEvent.startDate, end: newEndDate, calendars: nil)
            let eventsKitEvents = eventStore.events(matching: predicate)
            // asign newEndDate since recurrendEnd should not include the current event
            let events = eventsKitEvents.map { event in
                if(event.calendarItemIdentifier == ekEvent.calendarItemIdentifier){
                    newEndDate = event.startDate
                    // mark that the user did not select first event in the recurrence event
                    selectedFirstEvent = false
                }
            }
            
            // if the user select first recurrence event, delete all relate event
            if(selectedFirstEvent){
                performDelAllEvent(eventIdentifier: eventIdentifier)
            }
            // user did not select first recurrence event
            else{
                var rules = firstRecurrenceEvent.recurrenceRules
                if(rules != nil){
                    let rule: EKRecurrenceRule = (rules?[0])!
                    // initialize the end recurrence date
                    rule.recurrenceEnd = EKRecurrenceEnd.init(end: newEndDate)
                    do {
                        try self.eventStore.save(firstRecurrenceEvent, span: .thisEvent, commit: true)
                    } catch let e as NSError{
                        print("error \(e)")
                    }
                }
            }
        }
    }
    
    // MARK: - perform segue
    // prepare var when go back to CalendarViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "goBackToCalendarVC"){
            tapBtn()
            let destinationVC = segue.destination as! CalendarViewController
            destinationVC.firstLunch = true
            destinationVC.swipe = 0
            destinationVC.viewWillAppear(true)
        }
    }
    
    // MARK: - helper func
    // check and initialize nessecary var that will use to render tableView
    func perpareDetilsToShow(event: EKEvent){
        // status of event
        if(event.hasAttendees){
            if(participantStatus != nil) {
                var email = event.organizer?.url.absoluteString.replacingOccurrences(of: "mailto:", with: "")
                print("email \(email)")
                if(event.calendar.title == email){
                    print("Might need to send cancellation \(event.organizer?.isCurrentUser)")
                    // specify that this event need to send the cancellation to people
                    needToSendCancellation = true
                }
            }
        }
        // check recurrence
        if(event.hasRecurrenceRules){
            recurrence = true
        }
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
    
    // MARK: - Func that will react when user press button
    // func that will perform segue selectedEditCalendarSegue that will goBackToCalendarViewController
    @objc func goBackToCalendarViewController() {
        print("goBackToCalendarViewController")
        performSegue(withIdentifier: "goBackToCalendarVC", sender: self)
    }
    
    // use to make haptic when user click botton
    func tapBtn(){
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    
}
