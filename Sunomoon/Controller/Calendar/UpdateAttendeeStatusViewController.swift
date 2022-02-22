//
//  UpdateAttendeeStatusViewController.swift
//  Sunomoon
//
//  Created by Luksawee Phansri on 2/2/22.
//

import Foundation
import UIKit
import EventKit
import EventKitUI
import Contacts

class UpdateAttendeeStatusViewController: UIViewController, EKEventViewDelegate {
    
    @IBOutlet weak var modifySettingView: UIView!
    // load data from eventkit
    let eventStore = EKEventStore()
    var eventIdentifier: String?
    var ekEvent: EKEvent?
    var participantStatus: Int?
    let eventVC = EKEventViewController()
    
    override func viewDidLoad() {
        // set light mode only
        overrideUserInterfaceStyle = .light
        // lock screen
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        super.viewDidLoad()
        // check user authorized
        eventAccess()
    }
    
    // will use only user does not allow contact access and want to change setting
    @IBAction func pressedAcceptToModifySetting(_ sender: Any) {
        // used to open settning
        UIApplication.shared.open(URL.init(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
    }
    
    // will use only user does not allow contact access and does not want to change setting
    @IBAction func pressedCancelToModifySetting(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
    func eventAccess() {
        eventStore.requestAccess(to: .event) { [self] (granted, error) in
            if granted {
                // may not be called on the main thread..
                DispatchQueue.main.async {
                    contactAccess()
                }
            }
        }
    }
    
    func contactAccess(){
        switch CNContactStore.authorizationStatus(for: CNEntityType.contacts) {
        case .authorized:
            DispatchQueue.main.async {
                self.showEventViewController()
            }
        case .denied, .restricted, .notDetermined:
            view.backgroundColor = UIColor(named: "mediumGrey")
            modifySettingView.isHidden = false
        }
    }
    
    func showEventViewController() {
        // set EKEventViewController to use light theme
        eventVC.overrideUserInterfaceStyle = .light
        // get event
        let predicate = eventStore.predicateForEvents(withStart: ekEvent!.startDate, end: ekEvent!.endDate, calendars: nil)
        let eventsKitEvents = eventStore.events(matching: predicate)
        let events = eventsKitEvents.map { curEkEvent in
            if(curEkEvent.calendarItemIdentifier == ekEvent!.calendarItemIdentifier){
                eventVC.event = curEkEvent
            }
        }
        eventVC.delegate = self
        eventVC.allowsEditing = true
        eventVC.allowsCalendarPreview = true
        
        // customizing the toolbar where the accept/maybe/decline buttons appear
        let navCon = UINavigationController(rootViewController: eventVC)
        navCon.toolbar.isTranslucent = true
        navCon.toolbar.tintColor = UIColor.red
        navCon.modalPresentationStyle = .overFullScreen
        present(navCon, animated: false, completion: nil)
    }
    
    func eventViewController(_ controller: EKEventViewController, didCompleteWith action: EKEventViewAction) {
        performSegue(withIdentifier: "goBackToCalendarVC", sender: self)
    }
}

