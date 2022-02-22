//
//  ScheduleCalendarCell.swift
//  Sunomoon
//
//  Created by Luksawee Phansri on 12/27/21.
//

import Foundation
import UIKit
class ScheduleCalendarCell: UITableViewCell {
    @IBOutlet weak var schEventLabel: UILabel!
    @IBOutlet weak var schEventTimeLabel: UILabel!
    @IBOutlet weak var schDayLabel: UILabel!
    @IBOutlet weak var schDateLabel: UILabel!
    @IBOutlet weak var headerMonthLabel: UILabel!
    @IBOutlet weak var schEventTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var schEventBtmConstraint: NSLayoutConstraint!
    @IBOutlet weak var schEventStack: UIStackView!
    @IBOutlet weak var exclamationImg: UIImageView!
}
