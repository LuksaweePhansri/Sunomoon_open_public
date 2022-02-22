//
//  ConfirmDeleteCaledarCell.swift
//  Sunomoon
//
//  Created by Luksawee Phansri on 1/10/22.
//

import Foundation
import UIKit

class RegInfoDelCell
: UITableViewCell {
    @IBOutlet weak var remindDelLabel: UILabel!
    @IBOutlet weak var customLabel: UILabel!
}

class SingleCalendarDelCell: UITableViewCell {
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
}

class MultipleCalendarDelCell: UITableViewCell{
    @IBOutlet weak var allBtn: UIButton!
    @IBOutlet weak var allFutureBtn: UIButton!
    @IBOutlet weak var onlyThisEventBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
}

class SendCancellationCell: UITableViewCell{
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
}
