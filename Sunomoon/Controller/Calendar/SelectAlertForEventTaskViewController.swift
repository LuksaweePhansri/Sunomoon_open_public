//
//  SelectAlertForEventTaskViewController.swift
//  Sunomoon
//
//  Created by Luksawee Phansri on 7/29/21.
//

import Foundation
import UIKit

import EventKit


class SelectAlertForEventTaskViewController: UIViewController {
    let eventStore = EKEventStore()
    var calendar = CalendarData()
    override func viewDidLoad() {
        self.view.frame = CGRect(x: 0, y: 200, width: self.view.frame.width, height: self.view.frame.height - 400)
        self.view.layoutIfNeeded()
        super.viewDidLoad()
        calendar.requestAccessToCalendar()
//        getEventFromEventStore()
  //      calendar.setCalendar()

    }
    

    
//    func getEventFromEventStore() {
//        // Get the appropriate calendar.
//        var calendar = Calendar.current
//
//        // Create the start date components
//        var oneDayAgoComponents = DateComponents()
//        oneDayAgoComponents.day = -1
//        var oneDayAgo = calendar.date(byAdding: oneDayAgoComponents, to: Date())
//
//        // Create the end date components.
//        var oneYearFromNowComponents = DateComponents()
//        oneYearFromNowComponents.year = 1
//        var oneYearFromNow = calendar.date(byAdding: oneYearFromNowComponents, to: Date())
//
//        if let anAgo = oneDayAgo, let aNow = oneYearFromNow{
//            let predicate = eventStore.predicateForEvents(withStart: anAgo, end: aNow, calendars: nil)
//
//            let eventKitEvents = eventStore.events(matching: predicate)
//
//
//            let calendarKitEvents = eventKitEvents.map { eKEvent in
//                let ckEvent = EKEvent(eventStore: self.eventStore)
//                ckEvent.title = eKEvent.title
//                ckEvent.startDate = eKEvent.startDate
//                calendarC.calendar.append(CalendarModel(title: eKEvent.title))
//                print(ckEvent.title)
//                print(ckEvent.startDate)
//
//
//            }
//            print("totalN: \(calendarC.getTotalN())")
//            calendarC.calendar.removeAll()
//            print("totalN: \(calendarC.getTotalN())")
//        }
        
        
        
//        // Create the predicate from the event store's instance method.
//        var predicate: NSPredicate? = nil
//        if let anAgo = oneDayAgo, let aNow = oneYearFromNow {
//            predicate = eventStore.predicateForEvents(withStart: anAgo, end: aNow, calendars: nil)
//        }
//
//
//        // Fetch all events that match the predicate.
//        var events: [EKEvent]? = nil
//        if let aPredicate = predicate {
//            events = eventStore.events(matching: aPredicate)
//
//            print("yo")
//            print(events?.description)
//    }
    
    
//}
}
