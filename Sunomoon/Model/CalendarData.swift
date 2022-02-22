//
//  CalendarData.swift
//  Sunomoon
//
//  Created by Luksawee Phansri on 7/26/21.
//

import Foundation
import EventKit
struct CalendarData {
    static let instance = CalendarData()
    var calendar: [CalendarModel] = []
    let eventStore = EKEventStore()
    
    // to get user to authorize to access event
    func requestAccessToCalendar() {
        eventStore.requestAccess(to: .event) { isAuthorized, error in
            debugPrint(error ?? "No error in authorizing access event")
            guard isAuthorized else {
                print("User did not authorizeed to access event")
                return
            }
        }
    }
    
    // fetch calendar from local calendar to show in monthly
    mutating func setCalendarToShowMonthly1(date: Date) {
        calendar.removeAll()
        var prevPeriod = date - (31 * 86400 * 12)
        var futurePeriod = date + (31 * 86400 * 12)
        print("date: \(date)")
        print("prevPeriod: \(prevPeriod)")
        print("futurePeriod: \(futurePeriod)")
        let predicate = eventStore.predicateForEvents(withStart: date, end: futurePeriod, calendars: nil)
        let eventsKitEvents = eventStore.events(matching: predicate)
        
        let events = eventsKitEvents.map { ekEvent in
            calendar.append(CalendarModel(eventIdentifier: ekEvent.eventIdentifier, calendar: ekEvent.calendar, title: ekEvent.title, startDate: ekEvent.startDate, endDate: ekEvent.endDate, isAllDay: ekEvent.isAllDay, occurrenceDate: ekEvent.occurrenceDate, hasAttendees: ekEvent.hasAttendees, attendees: ekEvent.attendees, ekEvent: ekEvent))
            let ckEvent = EKEvent(eventStore: self.eventStore)
            ckEvent.title = ekEvent.title
        }
    }
    
    // fetch calendar from local calendar to show monthly (range is 3 years and 42 days)
    mutating func setCalendarToShowMonthly(date: Date) {
        let lock = NSLock()
        lock.lock()
        calendar.removeAll()
        var prevPeriod = date - (86400 * 366 * 3)
        var futurePeriod = date + (86400 * 42)
        //print("date2: \(date)")
        //print("prevPeriod2: \(prevPeriod)")
        //print("futurePeriod2: \(futurePeriod)")
        let predicate = eventStore.predicateForEvents(withStart: prevPeriod, end: futurePeriod, calendars: nil)
        let eventsKitEvents = eventStore.events(matching: predicate)
        let events = eventsKitEvents.map { ekEvent in
            calendar.append(CalendarModel(eventIdentifier: ekEvent.eventIdentifier, calendar: ekEvent.calendar, title: ekEvent.title, startDate: ekEvent.startDate, endDate: ekEvent.endDate, isAllDay: ekEvent.isAllDay, occurrenceDate: ekEvent.occurrenceDate, hasAttendees: ekEvent.hasAttendees, attendees: ekEvent.attendees, ekEvent: ekEvent))
        }
        lock.unlock()
    }
    
    // fetch calendar from local calendar to show monthly (range is 3 years and 7 days)
    mutating func setCalendarToShowWeekly(date: Date) {
        let lock = NSLock()
        lock.lock()
        calendar.removeAll()
        var prevPeriod = Calendar.current.date(byAdding: .year, value: -3, to: date)
        var futurePeriod = date + (86400 * 7)
        //print("date1: \(date)")
        //print("prevPeriod1: \(prevPeriod)")
        //print("futurePeriod1: \(futurePeriod)")
        let predicate = eventStore.predicateForEvents(withStart: prevPeriod!, end: futurePeriod, calendars: nil)
        let eventsKitEvents = eventStore.events(matching: predicate)
        let events = eventsKitEvents.map { ekEvent in
            calendar.append(CalendarModel(eventIdentifier: ekEvent.eventIdentifier, calendar: ekEvent.calendar, title: ekEvent.title, startDate: ekEvent.startDate, endDate: ekEvent.endDate, isAllDay: ekEvent.isAllDay, occurrenceDate: ekEvent.occurrenceDate, hasAttendees: ekEvent.hasAttendees, attendees: ekEvent.attendees, ekEvent: ekEvent))
        }
        lock.unlock()
    }
    
    // fetch calendar from local calendar to show monthly (range is 3 years and 7 days)
    mutating func setCalendarToShow90Days(date: Date) {
        let lock = NSLock()
        lock.lock()
        calendar.removeAll()
        var prevPeriod = Calendar.current.date(byAdding: .year, value: -3, to: date)
        var futurePeriod = Calendar.current.date(byAdding: .day, value: 90, to: date)
        print("date90: \(date)")
        print("prevPeriod90: \(prevPeriod)")
        print("futurePeriod90: \(futurePeriod)")
        let predicate = eventStore.predicateForEvents(withStart: prevPeriod!, end: futurePeriod!, calendars: nil)
        let eventsKitEvents = eventStore.events(matching: predicate)
        let events = eventsKitEvents.map { ekEvent in
            calendar.append(CalendarModel(eventIdentifier: ekEvent.eventIdentifier, calendar: ekEvent.calendar, title: ekEvent.title, startDate: ekEvent.startDate, endDate: ekEvent.endDate, isAllDay: ekEvent.isAllDay, occurrenceDate: ekEvent.occurrenceDate, hasAttendees: ekEvent.hasAttendees, attendees: ekEvent.attendees, ekEvent: ekEvent))
        }
        lock.unlock()
    }
    
    // fetch calendar from local calendar to show monthly (range is 3 years and 7 days)
    mutating func setCalendarToShow3Months(date: Date) {
        let lock = NSLock()
        lock.lock()
        calendar.removeAll()
        var prevPeriod = Calendar.current.date(byAdding: .year, value: -3, to: date)
        var futurePeriod = Calendar.current.date(byAdding: .month, value: 3, to: date)
        //print("date3: \(date)")
        //print("prevPeriod3: \(prevPeriod)")
        //print("futurePeriod3: \(futurePeriod)")
        let predicate = eventStore.predicateForEvents(withStart: prevPeriod!, end: futurePeriod!, calendars: nil)
        let eventsKitEvents = eventStore.events(matching: predicate)
        let events = eventsKitEvents.map { ekEvent in
            calendar.append(CalendarModel(eventIdentifier: ekEvent.eventIdentifier, calendar: ekEvent.calendar, title: ekEvent.title, startDate: ekEvent.startDate, endDate: ekEvent.endDate, isAllDay: ekEvent.isAllDay, occurrenceDate: ekEvent.occurrenceDate, hasAttendees: ekEvent.hasAttendees, attendees: ekEvent.attendees, ekEvent: ekEvent))
        }
        lock.unlock()
    }
    
    func getTotalEvents() -> Int {
        return calendar.count
    }
    
    func getEvent(date: Date) -> [CalendarModel] {
        let lock = NSLock()
        lock.lock()
        var events: [CalendarModel] = []
        var oneDayEvents: [CalendarModel] = []
        var severalDaysEvents: [CalendarModel] = []
        let calendarDate = Calendar.current
        let day = calendarDate.component(.day, from: date)
        let month = calendarDate.component(.month, from: date)
        let year = calendarDate.component(.year, from: date)
        // reset date
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        var resetDate = formatter.date(from: "\(year)/\(month)/\(day) 00:00")!
//        print(resetDate)
        var beginDate: Date = resetDate
        var endDate: Date = beginDate + (86400) - 60
//        print("time: \(beginDate): \(endDate)")
        for i in 0..<calendar.count {
            let beginEventDate = calendar[i].startDate
            let beginEventDay = calendarDate.component(.day, from: beginEventDate)
            let beginEventMonth = calendarDate.component(.month, from: beginEventDate)
            let beginEventYear = calendarDate.component(.year, from: beginEventDate)
            let endEventDate = calendar[i].endDate
            let endEventDay = calendarDate.component(.day, from: endEventDate)
            let endEventMonth = calendarDate.component(.month, from: endEventDate)
            let endEventYear = calendarDate.component(.year, from: endEventDate)
            // get one day
            if((beginEventDay == endEventDay) && (beginEventMonth == endEventMonth) && (beginEventYear == endEventYear)){
                if((day == beginEventDay) && (month == beginEventMonth) && (year == beginEventYear)){
                    oneDayEvents.append(CalendarModel(eventIdentifier: calendar[i].eventIdentifier, calendar: calendar[i].calendar ,title: calendar[i].title, startDate: calendar[i].startDate, endDate: calendar[i].endDate, isAllDay: calendar[i].isAllDay, occurrenceDate: calendar[i].occurrenceDate, hasAttendees: calendar[i].hasAttendees, attendees: calendar[i].attendees, ekEvent: calendar[i].ekEvent))
                }
            }
            // severalDays
            else {
                if((endDate >= beginEventDate) && (beginDate <= endEventDate)) {
//                    print("\(beginDate): \(endDate)")
//                    print("\(calendar[i].title): \(calendar[i].startDate): \(calendar[i].endDate)")
                    severalDaysEvents.append(CalendarModel(eventIdentifier: calendar[i].eventIdentifier, calendar: calendar[i].calendar ,title: calendar[i].title, startDate: calendar[i].startDate, endDate: calendar[i].endDate, isAllDay: calendar[i].isAllDay, occurrenceDate: calendar[i].occurrenceDate, hasAttendees: calendar[i].hasAttendees, attendees: calendar[i].attendees, ekEvent: calendar[i].ekEvent))
                }
            }
        }
        
        // sortEvents
       // severalDaysEvents.sort { calendarDate.dateComponents([.hour], from: $0.startDate, to: $0.endDate).hour! > calendarDate.dateComponents([.hour], from: $1.startDate, to: $1.endDate).hour!}
        severalDaysEvents.sort { $0.startDate < $1.startDate  }
        oneDayEvents.sort { $0.startDate < $1.startDate  }
        for event in severalDaysEvents{
            events.append(event)
        }
        for event in oneDayEvents{
            events.append(event)
        }
        lock.unlock()
        return events
    }
    
    func isOneDayEvent(startDate: Date, endDate: Date) -> Bool{
        let calendarDate = Calendar.current
        let beginEventDate = startDate
        let beginEventDay = calendarDate.component(.day, from: beginEventDate)
        let beginEventMonth = calendarDate.component(.month, from: beginEventDate)
        let beginEventYear = calendarDate.component(.year, from: beginEventDate)
        let endEventDate = endDate
        let endEventDay = calendarDate.component(.day, from: endEventDate)
        let endEventMonth = calendarDate.component(.month, from: endEventDate)
        let endEventYear = calendarDate.component(.year, from: endEventDate)
        if((beginEventDay == endEventDay) && (beginEventMonth == endEventMonth) && (beginEventYear == endEventYear)){
            return true
        }
        return false
    }
    
    func isDateOfEventStartDate(currDate: Date, eventStartDate: Date) -> Bool{
        return isOneDayEvent(startDate: currDate, endDate: eventStartDate)
    }
    
    func getHrToEndWeek(currDay: Int) -> Int{
        return (7 - currDay) * 24
    }
    
    func isEndDateLongerThanRemainCell(hrToEndEvent: Int, hrToEndWeek: Int) -> Bool{
        if(hrToEndEvent > hrToEndWeek) {
            return true
        }
        return false
    }
}
