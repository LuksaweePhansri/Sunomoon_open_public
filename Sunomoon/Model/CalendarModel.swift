//
//  CalendarModel.swift
//  Sunomoon
//
//  Created by Luksawee Phansri on 7/31/21.
//

import Foundation
import EventKit
struct CalendarModel {
    var eventIdentifier: String
    var calendar: EKCalendar
    var title: String
    var startDate: Date
    var endDate: Date
    var isAllDay: Bool
    var occurrenceDate: Date
    var hasAttendees: Bool
    var attendees: [EKParticipant]?
    var ekEvent: EKEvent?
}
