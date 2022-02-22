//
//  MenuCalendarViewController.swift
//  Sunomoon
//
//  Created by Luksawee Phansri on 8/4/21.
//

import Foundation
import UIKit

class MenuCalendarViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var schBtn: UIButton!
    @IBOutlet weak var weekBtn: UIButton!
    @IBOutlet weak var monthBtn: UIButton!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var menuView: UIView!
    
    var showMode: String = "Month"
    var fern: [String] = ["Fern", "Fern","Fern","Fern","Fern","Fern","Fern","Fern","Fern","Fern","Fern","Fern","Fern","Fern","Fern","Fern","Fern","Fern","Fern","Fern","Fern","Fern","Fern","Fern","Fern","Fern","Fern",]
    var swipe: Int = 0
    
    

    override func viewDidLoad() {
        print("menu view didload")
        // make app to have light theme
        overrideUserInterfaceStyle = .light
        // lock screen
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        super.viewDidLoad()
        // tap will use perform goBackToCalendarViewController that will take user to mainCalendar page
        let tap = UITapGestureRecognizer(target: self, action: #selector(goBackToCalendarViewController))
        bgView.addGestureRecognizer(tap)
        addSwipeRecognizer()
        // render manuView
        menuView.layer.cornerRadius = CGFloat(25)
        menuView.clipsToBounds = true
        // mark manuView corner to have curve
        menuView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        switch showMode {
        case "Schedule":
            schBtn.backgroundColor = UIColor(named: "lighterPastelBlue")
        case "Week":
            weekBtn.backgroundColor = UIColor(named: "lighterPastelBlue")
        default:
            monthBtn.backgroundColor = UIColor(named: "lighterPastelBlue")
        }
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: - func that will perform when user press botton
    @IBAction func pressedBtn(_ sender: UIButton) {
        tapBtn()
        print(sender.titleLabel?.text )
        showMode = sender.titleLabel?.text ?? "Month"
        performSegue(withIdentifier: "selectedSettingCalendarSegue", sender: self)
    }
    
    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 15
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "AccountNameCell") as! AccountNameCell
            cell.accountName.text = "luksawee@gmail.com"
            cell.detail.text = "Local calendars"
            tableView.rowHeight = 75
            return cell
        }

        else if(indexPath.row != 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailAccountCell") as! DetailAccountCell
            tableView.rowHeight = 65
            //cell.isSelectedImg.image = UIImage
            return cell
        }
        var cell = tableView.dequeueReusableCell(withIdentifier: "EndAccountCell", for: indexPath)
        return cell
    }
    
    // MARK: - prepare segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "selectedSettingCalendarSegue"){
            let destinationVC = segue.destination as! CalendarViewController
            destinationVC.showMode = showMode
            destinationVC.firstLunch = true
            destinationVC.swipe = 0
            // call viewWillAppear to style each showMode
            //destinationVC.viewDidLoad()
            destinationVC.viewWillAppear(true)
        }
    }
    
    // MARK: - Helper function
    @objc func goBackToCalendarViewController() {
        print("goBackToCalendarViewController")
        tapBtn()
        performSegue(withIdentifier: "selectedSettingCalendarSegue", sender: self)
    }
    
    // create the swipeGestureReconizer for all directions that will perform goBackToCalendarViewController
    func addSwipeRecognizer() {
        let directions: [UISwipeGestureRecognizer.Direction] = [.right, .left, .up, .down]
        for direction in directions {
            let gesture = UISwipeGestureRecognizer(target: self, action: #selector(goBackToCalendarViewController))
            gesture.direction = direction
            bgView.addGestureRecognizer(gesture)
            view.addGestureRecognizer(gesture)
        }
    }
    
    // use to make haptic when user click botton
    func tapBtn(){
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}
