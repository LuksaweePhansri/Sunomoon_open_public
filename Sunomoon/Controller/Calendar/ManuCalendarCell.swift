//
//  ManuCalendarCell.swift
//  Sunomoon
//
//  Created by Luksawee Phansri on 1/11/22.
//

import Foundation
import UIKit

// customize cell to show user account
class AccountNameCell: UITableViewCell {
    @IBOutlet weak var accountName: UILabel!
    @IBOutlet weak var detail: UILabel!
}

// customize cell to show detail in each account
class DetailAccountCell: UITableViewCell {
    @IBOutlet weak var isSelectedImg: UIImageView!
    @IBOutlet weak var detail: UILabel!
    @IBOutlet weak var isMutedImg: UIImageView!
    @IBAction func pressedSelectDetailCell(_ sender: Any) {
        print("cell is select")
    }
}
