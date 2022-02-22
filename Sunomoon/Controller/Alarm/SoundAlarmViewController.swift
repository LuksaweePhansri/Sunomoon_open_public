//
//  SoundAlarnViewControlller.swift
//  Sunomoon
//
//  Created by Luksawee Phansri on 2/18/21.
// i am test

import Foundation
import UIKit
import AVFoundation

class SoundAlarmViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var selectedSound: String?
    var currentSound: String?
    var player: AVAudioPlayer!
    
    @IBOutlet weak var tableView: UITableView!
    let soundArray = ["Default", "Bird song", "Wave sound", "UFO"]
    // Use to not allow user to get the auto rotation
    override var shouldAutorotate: Bool {
        return false
    }
    
    override func viewDidLoad() {
        title = "Sound"
        print("SoundAlarmVC")
        // make app to have light theme
        overrideUserInterfaceStyle = .light
        // lock to portrait
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
    }
    
    // MARK: - TableView DataSource Method
    // func to specify the number of the prototype cell
    func numberOfSections(in tableView: UITableView) -> Int {
        return soundArray.count
    }
    
    // func to call the table row to create the empthy row to store assign data
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    // func to assign data to each row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListAlarmSound", for: indexPath)
        // parmeter to set the size
        let itemSize = CGSize.init(width: 60, height: 60)
        UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.main.scale);
        let imageRect = CGRect.init(origin: CGPoint.zero, size: itemSize)
        // set cell to get the image
        cell.imageView?.image = UIImage(named: soundArray[indexPath.section])
        cell.backgroundColor = .white
        // set image to be the circle
        cell.imageView?.layer.cornerRadius = 30
        cell.imageView?.layer.masksToBounds = true
        // draw image to the desire size
        cell.imageView?.image!.draw(in: imageRect)
        cell.imageView?.image! = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // main title
        cell.textLabel?.text = soundArray[indexPath.section]
        //cell.textLabel?.textColor = UIColor(named: "lightpurple" )
        cell.textLabel?.font = UIFont.systemFont(ofSize: 18.0)
        
        // set the separator style
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        cell.separatorInset.bottom = 1
        cell.layer.cornerRadius = 25
        cell.layer.borderColor = UIColor.white.cgColor
        cell.layer.borderWidth = 2
        tableView.separatorStyle = .singleLine
        // to make the checkmark at the end of the current sound
        if(cell.textLabel?.text == currentSound){
            cell.selectionStyle = .none
            cell.accessoryType = .checkmark
        }
        return cell
    }
    
    // set space between cell
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    // set color of space
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = UIColor(named: "addEditAlarmBG" )
        return footerView
    }
    
    // set hight cell
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var cellHeight:CGFloat = CGFloat()
        cellHeight = 85
        return cellHeight
    }
    
    // func to get the selected row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // let indexPath = tableView.indexPathForSelectedRow() //optional, to get from any UIButton for example
        // to make checkmark at the end of the select sound
        let currentCell = tableView.cellForRow(at: indexPath)! as UITableViewCell
        // make tableview not have highlight
        tableView.deselectRow(at: indexPath, animated: true)
        currentCell.accessoryType = .checkmark
        selectedSound = currentCell.textLabel!.text!
        
        // play alarm sound
        let alarmSound = Bundle.main.url(forResource: selectedSound, withExtension: "mp3")
        // to make sound even though user mute
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try! AVAudioPlayer(contentsOf: alarmSound!)
            player.play()
            } catch {
              print(error)
            }
        
        // check if cells != currentCell --> mark no mark
        currentCell.setSelected(true, animated: true)
        currentCell.setSelected(false, animated: true)
        let cells = tableView.visibleCells
        for c in cells {
            if(c != currentCell) {
                c.accessoryType = .none
            }
        }
    }
    
    // func to get the deselected row
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let currentCell = tableView.cellForRow(at: indexPath)! as UITableViewCell
        currentCell.accessoryType = .none
    }
    
    // MARK: - action when user click btn
    // function t for user pressed save
    @IBAction func pressedSelectBtn(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "saveSoundAlarmSegue", sender: self)
    }
    
    // MARK: - prepare segue
    // used to prepare and store selectedSound and send it back to AddEditAlarmViewController if user press save
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if(segue.identifier == "saveSoundAlarmSegue")
        {
            let destinationVC = segue.destination as! AddEditAlarmViewController
            destinationVC.alarmSound = selectedSound ?? "Default"
        }
    }
}
