//
//  EditCalendarCell.swift
//  Sunomoon
//
//  Created by Luksawee Phansri on 8/8/21.
//

import Foundation
import UIKit
class RegInfoCalendarCell: UITableViewCell {
    @IBOutlet weak var iconImg: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var startDate: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var accountDetail: UILabel!
}

class ActionInvitationCell: UITableViewCell {
    @IBOutlet weak var responseBtn: UIButton!
}

class LocationCalendarCell: UITableViewCell {
    @IBOutlet weak var textView: UITextView!
}

class AlertCalendarCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
}

class NumberAttendeesCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
}

class AttendeeInfoCell: UITableViewCell {
    @IBOutlet weak var statusImg: UIImageView!
    @IBOutlet weak var attendeeLabel: UILabel!
    @IBAction func pressedTextBtn(_ sender: Any){
        print("pressedTextBtn")
    }
    @IBAction func pressedCallBtn(_ sender: Any){
        print("pressedCallBtn")
    }
}

class NoteCalendarCell: UITableViewCell {
    @IBOutlet weak var textView: UITextView!
}

class URLCalendarCell: UITableViewCell {
    @IBOutlet weak var textView: UITextView!
}

//class EditDelCalendarCell: UITableViewCell {
//    
//    
//    @IBAction func pressedEditBtn(_ sender: Any) {
//        print("pressedEditBtn")
//    }
//    @IBAction func pressedDelBtn(_ sender: Any) {
//        print("pressedDelBtn")
//    } 
//}

