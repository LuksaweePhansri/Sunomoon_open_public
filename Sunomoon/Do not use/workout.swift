////
////  SoundAlarnViewControlller.swift
////  Sunomoon
////
////  Created by Luksawee Phansri on 2/18/21.
//// i am test
//
//import Foundation
//import UIKit
//
//class workout: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
//    @IBOutlet weak var tableView: UITableView!
//    
//    let soundArray = ["Default", "BirdSound", "WaveSound"]
//    
//    override func viewDidLoad() {
//        tableView.dataSource = self
//        tableView.delegate = self
//        
//        super.viewDidLoad()
//    }
//    
//    
//    // MARK: - TableView DataSource Method
//    // func to specify the number of the prototype cell
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//    
//    // func to call the table row to create the empthy row to store assign data
//    unc tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return soundArray.count
//    }
//
//    // func to assign data to each row
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "ListAlarmSound", for: indexPath)
//        // main title
//        cell.textLabel?.text = soundArray[indexPath.row]
//        //cell.textLabel?.textColor = UIColor(named: "lightpurple" )
//        cell.textLabel?.font = UIFont.systemFont(ofSize: 16.0)
//        
//        // set the separator style
//        cell.preservesSuperviewLayoutMargins = false
//        cell.separatorInset = UIEdgeInsets.zero
//        cell.layoutMargins = UIEdgeInsets.zero
//        cell.separatorInset.bottom = 0.05
//        tableView.separatorStyle = .singleLine
//        
//        
//        // to make the checkmark at the end of the current sound
//        if(cell.textLabel?.text == currentSound){
//            cell.accessoryType = .checkmark
//        }
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        var cellHeight:CGFloat = CGFloat()
//        cellHeight = 100
//        return cellHeight
//        
//    }
//    
//    
//    // func to get the selected row
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        //let indexPath = tableView.indexPathForSelectedRow() //optional, to get from any UIButton for example
//        // to make checkmark at the end of the select sound
//        let currentCell = tableView.cellForRow(at: indexPath)! as UITableViewCell
//        currentCell.accessoryType = .checkmark
//        selectedSound = currentCell.textLabel!.text!
//        
//        // check if cells != currentCell --> mark no mark
//        currentCell.setSelected(true, animated: true)
//        currentCell.setSelected(false, animated: true)
//        let cells = tableView.visibleCells
//        for c in cells {
//            if(c != currentCell) {
//                c.accessoryType = .none
//            }
//        }
//        
//
//    }
//    
//    // func to get the deselected row
//    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        
//        let currentCell = tableView.cellForRow(at: indexPath)! as UITableViewCell
//        currentCell.accessoryType = .none
//        
//    }
//    
//    
//    
//    // function t for user pressed save
//    @IBAction func pressedSaveBtn(_ sender: UIBarButtonItem) {
//        print("pressed save btn")
//        self.performSegue(withIdentifier: "saveSoundAlarmSegue", sender: self)
//    }
//    
//    // used to prepare and store selectedSound and send it back to AddEditAlarmViewController if user press save
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
//    {
//        if(segue.identifier == "saveSoundAlarmSegue")
//        {
//            let destinationVC = segue.destination as! AddEditAlarmViewController
//            destinationVC.alarmSound = selectedSound ?? "Default"
//            print("seleted souund:", selectedSound)
//        }
//    }
//    
//    
//
//    
//
//    
//
//        
//        
// 
//}
