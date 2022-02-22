//
//  MainAlarmViewController.swift
//  Sunomoon
//
//  Created by Luksawee Phansri on 1/22/21.
//

import UIKit
import RealmSwift
class AlarmViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var updateSettingView: UIView!
    
    @IBAction func preesedUpdateSetting(_ sender: Any) {
        SelectedScene.instance.goToTodayVC()
        UIApplication.shared.open(URL.init(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
    }
    // load data rom Realm
    let realm = try! Realm()
    var alarmDatas: Results<AlarmData>?
    var alarmDataModel = AlarmData()
    
    // Use to not allow user to get the auto rotation
    override var shouldAutorotate: Bool {
        return false
    }
    
    override func viewDidLoad() {
        print("AlarmVC")
        // make app to have light theme
        overrideUserInterfaceStyle = .light
        // lock screen
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        // ask user to authorize service
        UserNotificationsService.instance.alarmAuthorizeNotification()
        // reschedule all alram
        AlarmService.instance.reSchedule()
        // allow cell to be able to select
        tableView.allowsSelectionDuringEditing = true
        // Do any additional setup after loading the view.
        // set cell height
        self.tableView.rowHeight = 100
        // connect tableView to view
        self.tableView.delegate = self
        self.tableView.dataSource = self
        // check notificationCenter
        checkUNUserNotificationCenter()
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("AlarmVC viewWillAppear")
        // To lock the scene to the portrait mode
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        // load data from realm
        alarmDatas = alarmDataModel.loadAlarmDatas()
        // to make each alarm has -
        if(alarmDatas!.count != 0) {
            self.navigationItem.leftBarButtonItem = self.editButtonItem
        }
        else{
            navigationItem.leftBarButtonItem = nil
        }
        // check notificationCenter
        checkUNUserNotificationCenter()
        // Reload table
        tableView.reloadData()
        super.viewWillAppear(animated)
    }
    
    func checkUNUserNotificationCenter(){
        let notification = UNUserNotificationCenter.current().getNotificationSettings { setting in
            switch setting.authorizationStatus {
            case .notDetermined:
                DispatchQueue.main.async { [self] in
                    viewDidLoad()
                }
            case .authorized:
                DispatchQueue.main.async {
                    self.updateSettingView.isHidden = true
                }
            default:
                DispatchQueue.main.async {
                    self.updateSettingView.isHidden = false
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Reset when view is being removed
        AppUtility.lockOrientation(.portrait)
        super.viewWillDisappear(animated)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: true)
    }
    
    // MARK: - TableView DataSource Method
    // func to specify the number of the prototype cell
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // func to call the table row to create the empthy row to store assign data
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alarmDatas?.count ?? 0
    }
    
    // func to assign data to each row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmCell", for: indexPath)
        //main title
        if (alarmDatas?[indexPath.row]) != nil {
            // title
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone.autoupdatingCurrent
            dateFormatter.timeStyle = DateFormatter.Style.short
            let strDate = dateFormatter.string(from: alarmDatas![indexPath.row].date)
            cell.textLabel?.text = strDate
            cell.textLabel?.textColor = UIColor(named: "midnightBlue")
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 32.0)
            // subtitle
            cell.detailTextLabel?.text = alarmDatas![indexPath.row].alarmLabel
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 16.0)
            // set the separator style
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsets.zero
            cell.layoutMargins = UIEdgeInsets.zero
            cell.separatorInset.bottom = 0.05
            tableView.separatorStyle = .none
            // add switch to the AlarmCell
            let switchView = UISwitch(frame: .zero)
            switchView.setOn(false, animated: true)
            if(alarmDatas![indexPath.row].enabled == true) {
                switchView.setOn(true, animated: true)
            }
            // assign switchView onset color
            switchView.onTintColor = UIColor(named: "skyColor" )
            switchView.thumbTintColor = UIColor(named: "lightGrey" )
            switchView.tag = indexPath.row
            switchView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
            cell.accessoryView = switchView
        }
        return cell
    }
    
    // select cell to edit
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "editSegue", sender: SelectedAlarmInfo(alarmIndex: indexPath.row))
    }
    
    @objc func switchChanged(_ sender : UISwitch!){
        // update enable to database
        if let alarmData = alarmDatas?[sender.tag] {
            do {
                try self.realm.write {
                    alarmData.enabled = sender.isOn
                }
            } catch {
                print("Cannot update enable/ disable alarm data, \(error)")
            }
        }
    }
    
    // method to swipe to delete in table view
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == .delete){
            if let alarmData = alarmDatas?[indexPath.row] {
                do {
                    try self.realm.write {
                        realm.delete(alarmData)
                    }
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    viewWillAppear(true)
                } catch {
                    print("Cannot delete alarm data, \(error)")
                }
            }
        }
    }
    
    // MARK: - prepare segue
    // func to x and unwind in AddEditAlarmView to go back to AlarmViewController
    @IBAction func unwindFromAddEditAlarmView(_ segue: UIStoryboardSegue) {
        print("go back to AlarmVC")
        self.viewWillAppear(true)
        isEditing = false
    }
    
    // prepare segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "editSegue"){
            let destinationVC = segue.destination as! UINavigationController
            let addEditAlarmVC = destinationVC.topViewController as! AddEditAlarmViewController
            addEditAlarmVC.isEditingMode = true
            addEditAlarmVC.selectedAlarmInfo = sender as! SelectedAlarmInfo
        }
    }
}
