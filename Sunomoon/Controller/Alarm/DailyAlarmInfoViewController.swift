//
//  DailyAlarmInfoViewController.swift
//  Sunomoon
//
//  Created by Luksawee Phansri on 6/10/21.
//

import Foundation
import UIKit
import CoreLocation
import EventKit

class EventCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
}
class DailyAlarmInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(isUserAuthorizeToAccessEvent){
            //tableView.rowHeight = UITableView.automaticDimension
            return events.count
        } else {
            tableView.rowHeight = 40
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventCell
        if(isUserAuthorizeToAccessEvent){
            cell.label.text = events[indexPath.row].title
            cell.label.numberOfLines = 1
            cell.label.sizeToFit()
            print(cell.label.bounds.height)
        }
        
        // user did not allow to show calendar
        else {
            cell.label.text = "Please allow us to access your calendar"
            cell.label.numberOfLines = 2
            cell.label.font = UIFont.boldSystemFont(ofSize: 16)
            cell.sizeToFit()
        }
        return cell
    }
    
    func tableView(tableView: UITableView,
        heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var periodPic: UIImageView!
    @IBOutlet weak var timeTogetPeriod: UILabel!
    @IBOutlet weak var emotionReminder: UILabel!
    @IBOutlet weak var periodStatus: UILabel!
    @IBOutlet weak var inLabel: UILabel!
    @IBOutlet weak var daysLabel: UILabel!
    @IBOutlet weak var calendarLable: UILabel!
    @IBOutlet weak var schTableView: UITableView!
    @IBOutlet weak var forecastPic: UIImageView!
    @IBOutlet weak var temp: UILabel!
    @IBOutlet weak var airQualityLevelLabel: UILabel!
    @IBOutlet weak var aqiLabel: UILabel!
    @IBOutlet weak var airQualityAdviseLabel: UILabel!
    @IBOutlet weak var tarotBtn: UIButton!
    @IBOutlet weak var middleCircle: UIImageView!
    @IBOutlet weak var leftBlueSquare: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var settingBtn: UIButton!
    @IBOutlet weak var accessStatusLabel: UILabel!
    @IBOutlet weak var updateStatusInfoLabel: UILabel!
    @IBOutlet weak var updateSettingView: UIView!
    @IBOutlet weak var totalCalendarLabel: UIButton!
    var locationManager = CLLocationManager()
    var weatherManager = WeatherManager()
    var airQualityManager = AirQualityManager()
    var calendarData = CalendarData()
    var events: [CalendarModel] = []
    var soundPlayer = SoundPlayer()
    var date = Date()
    var eventStore = EKEventStore()
    var needToUpdateSetting = false
    var isUserAuthorizeToAccessEvent: Bool = true
    var isUserAuthorizeToAccessLocation: Bool = true
    
    // Use to not allow user to get the auto rotation
    override var shouldAutorotate: Bool {
        return true
    }
    
    override func viewDidLoad() {
        // make app to have light theme
        overrideUserInterfaceStyle = .light
        print("DailyAlarmInfoVC")
        // lock to portrait
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        weatherManager.delegate = self
        locationManager.delegate = self
        airQualityManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        locationManager.startUpdatingLocation()
        setBackgroundComponents()
        soundPlayer.playSound(selectedSound: "MissionComplete")
        calendarData.setCalendarToShowMonthly(date: date)
        events = calendarData.getEvent(date: date)
        eventStore.requestAccess(to: .event) { isAuthorized, error in
            debugPrint(error ?? "No error in authorizing access event")
            guard isAuthorized else {
                self.needToUpdateSetting = true
                self.isUserAuthorizeToAccessEvent = false
                DispatchQueue.main.async {
                    self.settingUpdateView()
                }
                return
            }
        }

        if(events.count == 0){
            totalCalendarLabel.isHidden = true
        }
        else {
            totalCalendarLabel.setTitle("\(events.count)", for: .normal)
        }
        tableView.estimatedRowHeight = 44
        tableView.dataSource = self
        tableView.delegate = self
        super.viewDidLoad()
    }
    
    func settingUpdateView(){
        if(needToUpdateSetting){
            settingBtn.layer.cornerRadius = settingBtn.layer.bounds.width/2
            if(!isUserAuthorizeToAccessEvent){
                accessStatusLabel.text = "To know today schedule"
                updateStatusInfoLabel.text = "Press setting button to enable calendar access"
            }
            if(!isUserAuthorizeToAccessLocation){
                accessStatusLabel.text = "To see today weather"
                updateStatusInfoLabel.text = "Press setting button to enable location access"
            }
            if(!isUserAuthorizeToAccessEvent) && (!isUserAuthorizeToAccessLocation){
                accessStatusLabel.text = "To see today weather and calendar"
                updateStatusInfoLabel.text = "Press setting button to enable location and calendar access"
            }
        }
        updateSettingView.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Lock scene orientation
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // To lock other scence
        AppUtility.lockOrientation(.portrait)
    }
    
    //MARK: - press X btn
    @IBAction func pressedCloseBtn(_ sender: Any) {
        SelectedScene.instance.goToTodayVC()
    }
    
    //MARK: - set components
    func setBackgroundComponents() {
        middleCircle.layer.cornerRadius = middleCircle.layer.bounds.width/2
        tarotBtn.layer.cornerRadius = 15
        tarotBtn.layer.shadowColor = UIColor.darkGray.cgColor
        tarotBtn.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        tarotBtn.layer.shadowOpacity = 1.0
        tarotBtn.layer.shadowRadius = 2.0
        tarotBtn.layer.masksToBounds = false
        tarotBtn.titleLabel?.numberOfLines = 2
        tarotBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        tarotBtn.titleLabel?.textAlignment = .center
        closeBtn.layer.cornerRadius = closeBtn.layer.bounds.width/2
    }
}

// MARK: - WeatherManagerDelegate
extension DailyAlarmInfoViewController: WeatherManagerDelegate {
    func didUpdateWeather(weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
            self.middleCircle.backgroundColor = UIColor(named: "lightPastelPink")
            self.forecastPic.image = UIImage(named: weather.conditionName)
            self.temp.text = "\(weather.tempertureString) °F"
        }
    }
    
    func didWeatherManagerFailWithError(error: Error) {
        print(error)
    }
}

// MARK: - AirQualityManagerDelegate
extension DailyAlarmInfoViewController: AirQualityManagerDelegate {
    func didUpdateAirQuality(airQualityManager: AirQualityManager, airQuality: AirQualityModel) {
        DispatchQueue.main.async {
            self.airQualityLevelLabel.text = "Air Quality: \(airQuality.airQualityLevel)"
            self.aqiLabel.text = "Air Quality Index: \(airQuality.aqiString)"
            self.airQualityAdviseLabel.text = airQuality.airQualityAdvise
        }
    }

    func didAirQualityManagerFailWithError(error: Error) {
        print(error)
    }
}

// MARK: - CLLocationManagerDelegate
extension DailyAlarmInfoViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weatherManager.getCurrentLocationWeather(lat: lat, lon: lon)
            airQualityManager.getCurrentLocationAirQuality(lat: lat, lon: lon)
        }
    }
    
    // case user does not allow app to access location
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        needToUpdateSetting = true
        isUserAuthorizeToAccessLocation = false
        print(error)
        DispatchQueue.main.async {
            self.settingUpdateView()
        }
    }
    
    // touch action that will pop up setting for user to change app setting
    @IBAction func pressedModifySetting(_ sender: Any) {
        if let url = URL.init(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
