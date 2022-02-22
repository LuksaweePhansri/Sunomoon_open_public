//
//  WeekCalendarView.swift
//  Sunomoon
//
//  Created by Luksawee Phansri on 8/6/21.
//

import Foundation
import UIKit
class WeekCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var headLineColor: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var beginTimeLabel: UILabel!
    @IBOutlet weak var periodLabel: UILabel!
    @IBOutlet weak var exclamationmark: UIImageView!
    @IBOutlet weak var exclamationmarkWidth: NSLayoutConstraint!
    @IBOutlet weak var exclamationmarkHeight: NSLayoutConstraint!
}

class WeekTableCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var weekCollectionView: UICollectionView!
    @IBOutlet weak var weekDay: UILabel!
    @IBOutlet weak var day: UILabel!
    @IBOutlet weak var stackWeekDay: UIStackView!
    var row: Int = -1
    
    var calendarData = CalendarData()
    var selectedDate: Date?
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        //print("setSelected")
        //print("selectedDate: \(selectedDate)")
        super.setSelected(selected, animated: animated)
        weekCollectionView.reloadData()
    }
    
    // load data
    override func awakeFromNib() {
        //print("awakeFromNib")
        super.awakeFromNib()
        weekCollectionView.delegate = self
        weekCollectionView.dataSource = self
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    // data in each cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //print("cellForItemAt")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeekCollectionViewCell", for: indexPath) as! WeekCollectionViewCell
        cell.textView.textContainerInset = .zero
        cell.textView.text = "hello"
        return cell
    }
    
    // default number of cell in each section
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
}




