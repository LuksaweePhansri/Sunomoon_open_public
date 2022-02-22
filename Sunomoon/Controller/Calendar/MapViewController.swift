//
//  MapViewController.swift
//  Sunomoon
//
//  Created by Luksawee Phansri on 2/17/22.
//

import Foundation
import UIKit

class MapCalendarViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row == 0){
            // cell You're deleting an event
            let cell = tableView.dequeueReusableCell(withIdentifier: "RegInfoMapCalendarCell") as! RegInfoMapCalendarCell

            return cell
        }
        if(indexPath.row == 1){
            // cell You're deleting an event
            let cell = tableView.dequeueReusableCell(withIdentifier: "NavigatorAppCalendarCell") as! NavigatorAppCalendarCell

            return cell
        }
        if(indexPath.row == 2){
            // cell You're deleting an event
            let cell = tableView.dequeueReusableCell(withIdentifier: "CancelMapCalendarCell") as! CancelMapCalendarCell

            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "NavigatorAppCalendarCell") as! NavigatorAppCalendarCell
        return cell
    }
    
    // tableView height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 120
        
        if(indexPath.row == 2){
            height = 100
        }
        return height
    }
    
    override func viewDidLoad() {
        print("MapCalendarViewController")
        // make app to have light theme
        overrideUserInterfaceStyle = .light
        // lock screen
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        guide = self.view.safeAreaLayoutGuide
        remainViewToshowTableView = view.bounds.height - view.safeAreaLayoutGuide.layoutFrame.height
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.cornerRadius = 30
        tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        super.viewDidLoad()
    }
}
