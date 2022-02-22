//
//  CustomTapGestureRecognizer.swift
//  Sunomoon
//
//  Created by Luksawee Phansri on 8/7/21.
//

import Foundation
import UIKit
import EventKit

class CustomTapGestureReconizerForCalendar: UITapGestureRecognizer {
    var eventIdentifier: String?
    var participantStatus: Int?
    var ekEvent: EKEvent?
    var title: String?
}


class CustomTapGestureReconizerToOpenMap: UITapGestureRecognizer {
    var eventIdentifier: String?
    var participantStatus: Int?
    var ekEvent: EKEvent?
    var title: String?
    var textView: UITextView?
}

