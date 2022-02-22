//
//  TrackViewController.swift
//  Sunomoon
//
//  Created by Luksawee Phansri on 1/27/21.
//
import Foundation
import UIKit
import FSCalendar
import EventKit
// MARK: - Struct that will use to render calendar
// struct to record the invitation status
struct InvitedEventModel {
    var participantStatus: Int?
    var isInvitedEventNeedAction: Bool = false
}

// struct schedule calendar tye which will use to check type of event: header or body
struct ScheduleEvents {
    var type: String
    var event: CalendarModel?
}

// struct monthly calendar type
struct SelectedEventsMonthCalendar {
    var date: Date
    var eventsNumber: Int
    // [0, 0, 0, 0, 0]
    // 0 = do not have the calendar
    // 1 = several days of event with the START day that will NOT end in this week
    // 2 = several days of event with the START day that will end in this week
    // 3 = several days of event with NOT start day that will NOT end in this week
    // 4 = several days of event with NOT start day that will end in this week
    // 5 = one day
    var remark: [Int] = [0, 0, 0, 0, 0]
    var calendar = [CalendarModel?](repeating: nil, count: 5)
}
// MARK: - Main function
// main class for CalendarViewController
class CalendarViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDataSourcePrefetching {
    // data in each cell
    @IBOutlet weak var headerLabel: UIButton!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var tasksBtn: UIButton!
    @IBOutlet weak var weekTableView: UITableView!
    @IBOutlet weak var weekView: UIView!
    @IBOutlet weak var monthView: FSCalendar!
    @IBOutlet weak var scheduleView: UIView!
    @IBOutlet weak var scheduleTableView: UITableView!
    @IBOutlet weak var updateSettingView: UIView!
    
    
    // var that relate to load event from local calendar
    fileprivate let gregorian: NSCalendar! = NSCalendar(calendarIdentifier:NSCalendar.Identifier.gregorian)
    var calendarData = CalendarData()
    var selectedDate: Date = Date()
    var eventStore = EKEventStore()
    var loadedDate: Date = Date()           // use for the  first time loaded
    var showMode: String = "Month"
    let fullMonthString: [String] = ["January", "February", "March", "April", "May", "June",
                                     "July", "August", "September", "October", "November", "December"]
    let shortMonthString: [String] = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
                                      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    
    // Month
    var color: [String] = ["pastelBlue", "lightPastelBlue", "lighterPastelBlue", "lightestPastelBlue", "superLightestPastelBlue"]
    var selectedEventsMonthCalendar: [SelectedEventsMonthCalendar] = []
    let cellTag: Int = 247
    
    // Week
    var weekLabelWidth = 50
    var selecedDateForWeek: [Date] = []
    var weekIndex: Int = 0
    var weekDayText: [String] = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    var weekDayColor: [String] = ["sunColor", "monColor", "tueColor", "wedColor", "thuColor", "friColor", "satColor"]
    var bgEventColor: [String] = ["sunEventColor", "monEventColor", "tueEventColor", "wedEventColor", "thuEventColor", "friEventColor", "satEventColor"]
    var numberOfEventsAtSelectedDate: Int = 0
    
    // Schedule
    var dateToFetchSchEvents: Date = Date()
    var scheduleEvents:[ScheduleEvents] = []
    var scheduleEventsNumber: Int = 0
    var scheduleDate: [Date] = []
    var scheduleRowIndex: Int = 0
    var firstDateToFetchSchEvents: Date = Date()
    var firstLunch: Bool = true
    var firstLunchRowIndex: Int = 0
    var swipe: Int = 0
    
    // var that relate to EditCalendarVC
    var eventIdentifier: String?
    var statusInvitation: Int?
    var participantStatus: Int?
    var ekEvent: EKEvent?
    
    //MARK: - view
    override func viewDidLoad() {
        print("CalendarViewController0")
        // allow to have only light theme
        overrideUserInterfaceStyle = .light
        // lock screen
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        print("calendar viewdidload: \(selectedDate)")
        loadedDate = selectedDate
        print("number of swipe \(swipe)")
        print("loadedDate \(loadedDate)")
        super.viewDidLoad()
        // add observor that will use to reload ater scence become active that will use to reload monthView
        NotificationCenter.default.addObserver(self, selector: #selector(storeChanged(_:)), name: .EKEventStoreChanged, object: eventStore)
    }
    
    // to update when some events are changed
    @objc private func storeChanged(_ notification: Notification) {
        viewWillAppear(false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("CalendarViewController viewWillAppear")
        // To lock the scene to the portrait mode
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        print("calendar viewWillAppear date: \(selectedDate)")
        if(swipe == 0){
            loadedDate = selectedDate
        }
        setCalardar()
        switch showMode {
        case "Schedule":
            print("Schedule")
            print("date: \(dateToFetchSchEvents)")
            loadNextDataForScheduleMode()
            print("load till Date: \(dateToFetchSchEvents)")
            scheduleTableView.reloadData()
        case "Week":
            print("week")
            weekTableView.reloadData()
        default:
            print("month in viewWillAppear")
            // to show the selectedDate
            monthView.allowsSelection = true
            monthView.select(selectedDate)
            calendarCurrentPageDidChange(monthView)
            monthView.allowsSelection = false
        }
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Reset when view is being removed
        print("viewWillDisappear")
        AppUtility.lockOrientation(.portrait)
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Check authorization
    func eventAccess() {
        eventStore.requestAccess(to: .event) { [self] (granted, error) in
            if granted {
                DispatchQueue.main.async {
                    updateSettingView.isHidden = true
                    addBtn.isHidden = false
                }
            } else {
                DispatchQueue.main.async {
                    updateSettingView.isHidden = false
                    addBtn.isHidden = true
                }
            }
        }
    }
    
    // MARK: - monthView
    // will use to select date
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("didSelect")
        selectedDate = date
        let formatter = DateFormatter()
        let day: Int = self.gregorian.component(.day, from: date)
        let month: Int = self.gregorian.component(.month, from: date)
        let year: Int = self.gregorian.component(.year, from: date)
        formatter.dateFormat = "EEEE MMM-dd-YYYY at h:mm a"
        let string = formatter.string(from: date)
        print("Date: \(string)")
    }
    
    // use to show month header and fetching from local calendar in monthly month
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        print("calendarCurrentPageDidChange")
        //to lock thread
        let lock = NSLock()
        // get the selected date from calendar
        let currentPageDate = calendar.currentPage
        print("currentPageDate \(currentPageDate)")
        let month = Calendar.current.component(.month, from: currentPageDate)
        let year = Calendar.current.component(.year, from: currentPageDate)
        // will use to check that is it the first lunch
        if(selectedDate != currentPageDate){
            swipe += 1
        }
        selectedDate = currentPageDate
        
        //load data
        lock.lock()
        calendarData.setCalendarToShowMonthly(date: selectedDate)
        lock.unlock()
        let monthString: String = getStringMonth(monthIndex: month)
        headerLabel.setTitle("\(monthString) \(String(year))", for: .normal)
        prepareDataToShowInMonthlyCalendar(firstDateOfMonth: selectedDate)
        firstLunch = false
        monthView.reloadData()
        print("number of swipe: \(swipe)")
    }
    
    // func to show schedule in monthly
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        // get weekday from date
        let weekday = Calendar.current.component(.weekday, from: date)
        // assign cell that will use to show monthView
        var cell = calendar.dequeueReusableCell(withIdentifier: "CellWithPlan", for: date, at: position)
        cell.backgroundColor = UIColor.clear
        // re assign cell width
        var defaultCell = calendar.dequeueReusableCell(withIdentifier: "CellEmpty", for: date, at: position)
        var frame = cell.frame
        frame.size.width = cell.bounds.width
        cell.frame = frame
        // use to reset cell
        for subView in cell.subviews {
            if(subView.tag == cellTag) {
                subView.removeFromSuperview()
            }
        }
        // use to show cell each day in monthly
        var btn = [UIButton?](repeating: nil, count: 5)
        // get index that will use in selectedEventsMonthCalendar
        var index = getPositionInMonthlyCalendar(cellDate: date)
        if(index >= 42) {
            index = 41
        }
        if(index < 0) {
            index = 0
        }
        var events = selectedEventsMonthCalendar[index]
        var eventNumber = events.eventsNumber
        var eventText = events.calendar
        var remark = events.remark
        // to show event case more than 5 event
        if(eventNumber > 5){
            var moreEventsLabel = UILabel(frame: CGRect(x: (defaultCell.bounds.width/4 * 3)-1, y: cell.bounds.height/8 * CGFloat(2), width: defaultCell.bounds.width / 4, height: cell.bounds.height/8))
            moreEventsLabel.tag = cellTag
            moreEventsLabel.layer.cornerRadius = defaultCell.bounds.width / 8
            moreEventsLabel.text = "+\(eventNumber - 5)"
            moreEventsLabel.layer.backgroundColor = UIColor.lightGray.cgColor
            moreEventsLabel.textAlignment = .center
            moreEventsLabel.font = UIFont.systemFont(ofSize: 7)
            cell.addSubview(moreEventsLabel)
        }
        // assign calendar to cell
        for i in 0...4 {
            if(eventText[i] != nil){
                var divY = 3 + i
                // label that will seperate each event
                let cellHeight: CGFloat = (cell.bounds.height/8)-1
                var label = UILabel(frame: CGRect(x: 1, y: cell.bounds.height/8 * CGFloat(divY), width: 2, height: cellHeight))
                label.tag = cellTag
                label.backgroundColor = UIColor(named: "workBlue")
                // style btns
                btn[i] = UIButton(frame: CGRect(x: 1, y: cell.bounds.height/8 * CGFloat(divY), width: defaultCell.bounds.width - 2, height: cellHeight))
                btn[i]?.tag = cellTag
                btn[i]?.titleLabel?.font = UIFont.systemFont(ofSize: 11)
                btn[i]?.setTitleColor(.black, for: .normal)
                btn[i]?.titleLabel?.numberOfLines = 1
                btn[i]?.titleLabel?.lineBreakMode = .byClipping
                btn[i]?.contentHorizontalAlignment = .left
                btn[i]?.setTitle(" \(eventText[i]!.title)", for: .normal)
                btn[i]?.layer.backgroundColor = UIColor(named: color[i])?.cgColor
                // several days event
                if(remark[i] != 5) {
                    // several days of event with the START day that will NOT end in this week
                    if(remark[i] == 1){
                        btn[i]?.layer.frame = CGRect(x: 1, y: cell.bounds.height/8 * CGFloat(divY), width: (defaultCell.bounds.width * CGFloat((7-weekday+1))) - 2, height: cellHeight)
                    }
                    // several days of event with the START day that will end in this week
                    else if(remark[i] == 2){
                        let endEventWeekday = Calendar.current.component(.weekday, from: eventText[i]!.endDate)
                        btn[i]?.layer.frame = CGRect(x: 1, y: cell.bounds.height/8 * CGFloat(divY), width: (defaultCell.bounds.width * CGFloat((endEventWeekday-weekday+1))) - 2, height: cellHeight)
                    }
                    // several days of event with NOT start day
                    else if(remark[i] == 3)||(remark[i] == 4){
                        // sunday
                        if(weekday == 1){
                            if(remark[i] == 3){
                                btn[i]?.layer.frame = CGRect(x: 1, y: cell.bounds.height/8 * CGFloat(divY), width: (defaultCell.bounds.width * CGFloat(7)) - 2, height: cellHeight)
                            }
                            else {
                                let endEventWeekday = Calendar.current.component(.weekday, from: eventText[i]!.endDate)
                                btn[i]?.layer.frame = CGRect(x: 1, y: cell.bounds.height/8 * CGFloat(divY), width: (defaultCell.bounds.width * CGFloat((endEventWeekday-weekday+1))) - 2, height: cellHeight)
                            }
                        }
                        // not sunday
                        else {
                            btn[i]?.backgroundColor = UIColor.clear
                            btn[i]?.setTitleColor(UIColor.clear, for: .normal)
                            label.backgroundColor = UIColor.clear
                        }
                    }
                }
                // add action to btn
                var tabGesture = CustomTapGestureReconizerForCalendar(target: self, action: #selector(tabCalendar(sender:)))
                tabGesture.eventIdentifier = eventText[i]?.eventIdentifier
                tabGesture.ekEvent = eventText[i]?.ekEvent
                btn[i]?.addGestureRecognizer(tabGesture)
                // case the event need action
                var currentEvent = checkInvitedEvent(event: eventText[i]!)
                // check participant status
                if(currentEvent.participantStatus != nil){
                    tabGesture.participantStatus = currentEvent.participantStatus
                }
                
                // render ! for the events that need to review the invitation status
                if(currentEvent.isInvitedEventNeedAction){
                    // one day event or start day
                    if(remark[i] == 5)||(remark[i] == 1)||(remark[i] == 2) {
                        btn[i]?.imageView?.contentMode = .scaleAspectFit
                        btn[i]?.setImage(UIImage(systemName: "questionmark.circle.fill"), for: .normal)
                        btn[i]?.tintColor = UIColor.lightGray
                        label.backgroundColor = UIColor(named: "pastelOrange")
                    }
                    // several days of event with NOT start day
                    else if(remark[i] == 3)||(remark[i] == 4){
                        // sunday
                        if(weekday == 1){
                            btn[i]?.imageView?.contentMode = .scaleAspectFit
                            btn[i]?.setImage(UIImage(systemName: "questionmark.circle.fill"), for: .normal)
                            btn[i]?.tintColor = UIColor.lightGray
                            label.backgroundColor = UIColor(named: "pastelOrange")
                        }
                    }
                }
                // render botton
                if((btn[i] != nil)){
                    cell.addSubview(btn[i]!)
                    cell.addSubview(label)
                }
            }
        }
        return cell
    }
    
    // MARK: - WeekView and SceduleView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRow: Int = 0
        if(showMode == "Week") {
            weekTableView.rowHeight = (view.bounds.height - 10) / 7
            numberOfRow = 7
        }
        if(showMode == "Schedule") {
            numberOfRow = scheduleEventsNumber
        }
        return numberOfRow
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // week mode
        if(showMode == "Week") {
            weekIndex = indexPath.row
            //print("week index \(indexPath.row)")
            let cell = weekTableView.dequeueReusableCell(withIdentifier: "WeekTableCell", for: indexPath) as! WeekTableCell
            cell.selectedDate = selectedDate
            
            if(selecedDateForWeek != nil){
                if(indexPath.row <= 6){
                    //print("indexPath.row \(indexPath.row)")
                    cell.weekDay.text = weekDayText[indexPath.row]
                    cell.stackWeekDay.backgroundColor = UIColor(named: weekDayColor[indexPath.row])
                    cell.day.text = "\(Calendar.current.component(.day, from: selecedDateForWeek[indexPath.row]))"
                }
            }
            cell.row = indexPath.row
            cell.weekCollectionView.delegate = self
            cell.weekCollectionView.dataSource = self
            // case user swipe the tableView to go prev or next week
            let swipeToPrevWeek = UISwipeGestureRecognizer(target: self, action: #selector(swipeToPrevWeek(sender:)))
            swipeToPrevWeek.direction = .right
            cell.addGestureRecognizer(swipeToPrevWeek)
            let swipeToNextWeek = UISwipeGestureRecognizer(target: self, action: #selector(swipeToNextWeek(sender:)))
            swipeToNextWeek.direction = .left
            cell.addGestureRecognizer(swipeToNextWeek)
            return cell
        }
        
        // schedule mode
        if(showMode == "Schedule"){
            scheduleRowIndex = indexPath.row
            let cell = scheduleTableView.dequeueReusableCell(withIdentifier: "SchCell", for: indexPath) as! ScheduleCalendarCell
            // get date
            let currentDate = scheduleDate[indexPath.row]
            let formatter = DateFormatter()
            //print("tableView cellForRowAt: \(indexPath.row) date: \(currentDate)")
            // case header
            if(scheduleEvents[indexPath.row].type == "header"){
                scheduleTableView.rowHeight = 100
                cell.backgroundColor = UIColor(named: "lightGrey")
                formatter.dateFormat = "MMMM YYYY"
                let dateString = formatter.string(from: currentDate)
                cell.headerMonthLabel.text = dateString
                cell.headerMonthLabel.isHidden = false
                cell.schEventTimeLabel.isHidden = true
                cell.schEventLabel.isHidden = true
                cell.schDayLabel.isHidden = true
                cell.schDateLabel.isHidden = true
                cell.schEventStack.isHidden = true
                cell.exclamationImg.isHidden = true
            }
            // case event
            else{
                scheduleTableView.rowHeight = 65
                cell.backgroundColor = .white
                cell.schEventStack.layer.cornerRadius = 10
                cell.schEventLabel.text = scheduleEvents[indexPath.row].event?.title
                cell.schEventLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
                cell.schEventTimeLabel.isHidden = false
                cell.schEventLabel.isHidden = false
                cell.schDayLabel.isHidden = true
                cell.schDateLabel.isHidden = true
                cell.headerMonthLabel.isHidden = true
                cell.schEventStack.isHidden = false
                cell.exclamationImg.isHidden = true
                let startDate = scheduleEvents[indexPath.row].event?.startDate
                let endDate = scheduleEvents[indexPath.row].event?.endDate
                formatter.dateFormat = "h:mm a"
                let stringStartDate = formatter.string(from: startDate!)
                let stringEndDate = formatter.string(from: endDate!)
                // one day event
                if(calendarData.isOneDayEvent(startDate: startDate!, endDate: endDate!)){
                    cell.schEventTimeLabel.text = "\(stringStartDate) - \(stringEndDate)"
                }
                // several day events
                else {
                    cell.schEventTimeLabel.text = "Until \(stringEndDate)"
                }
                // case first event of that date
                if(scheduleEvents[indexPath.row].type == "eventFirstDate") {
                    formatter.dateFormat = "EEE"
                    let dateString = formatter.string(from: currentDate)
                    cell.schDayLabel.text = dateString
                    cell.schDayLabel.isHidden = false
                    let day: Int = self.gregorian.component(.day, from: currentDate)
                    cell.schDateLabel.text = String(day)
                    cell.schDateLabel.isHidden = false
                    cell.schEventTopConstraint.constant = 10
                }
                if(scheduleEvents[indexPath.row].type == "event") {
                    scheduleTableView.rowHeight = 55
                    cell.schEventTopConstraint.constant = 0
                }
                // add tapgesture
                var tabGesture = CustomTapGestureReconizerForCalendar(target: self, action: #selector(tabCalendar(sender:)))
                tabGesture.eventIdentifier = scheduleEvents[indexPath.row].event?.eventIdentifier
                tabGesture.ekEvent = scheduleEvents[indexPath.row].event?.ekEvent
                cell.addGestureRecognizer(tabGesture)
                
                // case the event need action
                let currentEvent = checkInvitedEvent(event: scheduleEvents[indexPath.row].event!)
                if(currentEvent.participantStatus != nil){
                    tabGesture.participantStatus = currentEvent.participantStatus
                }
                if(currentEvent.isInvitedEventNeedAction){
                    cell.exclamationImg.isHidden = false
                }
            }
            return cell
        }
        // case something wrong
        print("something wrong in schedule")
        let cell = weekTableView.dequeueReusableCell(withIdentifier: "WeekTableCell", for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(showMode == "Week"){
            weekIndex = indexPath.row
            weekTableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    // func that will use to render the headerLabel in Schedule moe
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if(showMode == "Schedule"){
            if(firstLunch){
                let indexPath = IndexPath(row: firstLunchRowIndex, section: 0)
                self.scheduleTableView.scrollToRow(at: indexPath, at: .top, animated: false)
                firstLunch = false
            }
            if(indexPath.row + 1 == scheduleEventsNumber){
                loadNextDataForScheduleMode()
                scheduleTableView.reloadData()
            }
            // get the visible row 1
            let ip = self.scheduleTableView.indexPathsForVisibleRows![1]
            // get date
            let currentDate = scheduleDate[ip.row]
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMMM YYYY"
            let dateString = formatter.string(from: currentDate)
            headerLabel.setTitle(dateString, for: .normal)
            selectedDate = scheduleDate[ip.row]
        }
    }
    
    // func that will use to load theprev 3 month when user reach to the topest use margin 200
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(showMode == "Schedule"){
            if (scheduleTableView.contentOffset.y + scheduleTableView.safeAreaInsets.top) < 200 {
                print("toppest")
                loadPrevDataForScheduleMode()
            }
        }
    }
    
    // func tableView that will use to prefetch and assign data to scheduleEvents and scheduleDate
    // use this func to make tableView run smooth
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        //print("prefetch")
        if(showMode == "Schedule"){
            let bottomrow = IndexPath(row: scheduleEventsNumber - 5, section: 0)
            if(indexPaths.contains(bottomrow)) {
                loadNextDataForScheduleMode()
                scheduleTableView.reloadData()
            }
        }
    }
    
    // MARK: - collectionView that will use in WeekView
    // number of cell in each section
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(weekIndex < 7){
            //print("collectionView number of cell: \(calendarData.getEvent(date: selecedDateForWeek[weekIndex]).count)")
            numberOfEventsAtSelectedDate = 0
            numberOfEventsAtSelectedDate = calendarData.getEvent(date: selecedDateForWeek[weekIndex]).count
            return numberOfEventsAtSelectedDate
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //print("Row: \(indexPath.row)")
        //print("Item: \(indexPath.item)")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeekCollectionViewCell", for: indexPath) as! WeekCollectionViewCell
        if((indexPath.row <= numberOfEventsAtSelectedDate) && (numberOfEventsAtSelectedDate != 0)){
            // head color
            cell.headLineColor.backgroundColor = UIColor(named: weekDayColor[weekIndex])
            // set title
            let calendar = calendarData.getEvent(date: selecedDateForWeek[weekIndex])[indexPath.row]
            let calendarTitle: String = calendar.title
            if(calendarTitle != ""){
                cell.textView.text = calendarTitle
            }
            else {
                cell.textView.text = "No title"
            }
            cell.backgroundColor = UIColor(named: bgEventColor[weekIndex])
            cell.textView.textContainerInset = .zero
            cell.exclamationmarkWidth.constant = 0
            cell.exclamationmarkHeight.constant = 0
            
            // set beginTimeLabel
            let startDate = calendar.startDate
            let endDate = calendar.endDate
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            var stringStartDate = formatter.string(from: startDate)
            let stringEndDate = formatter.string(from: endDate)
            cell.beginTimeLabel.backgroundColor = .lightGray
            // one day event
            if(calendarData.isOneDayEvent(startDate: startDate, endDate: endDate)){
                cell.beginTimeLabel.text = "\(stringStartDate)"
                var startDateComponent = Calendar.current.dateComponents([.hour, .minute], from: startDate)
                var endDateComponent = Calendar.current.dateComponents([.hour, .minute], from: endDate)
                var periodTime: String = ""
                var eventHr = endDateComponent.hour! - startDateComponent.hour!
                var eventMin = endDateComponent.minute! - startDateComponent.minute!
                if(eventHr > 0){
                    periodTime.append("\(eventHr) hr ")
                }
                if(eventMin > 0){
                    periodTime.append("\(eventMin) min")
                }
                cell.periodLabel.text = periodTime
                if(calendar.isAllDay){
                    cell.beginTimeLabel.text = ""
                    cell.beginTimeLabel.backgroundColor = UIColor(named: bgEventColor[weekIndex])
                    cell.periodLabel.text = "All-day"
                }
            }
            else {
                if(calendar.isAllDay){
                    cell.beginTimeLabel.text = ""
                    cell.beginTimeLabel.backgroundColor = UIColor(named: bgEventColor[weekIndex])
                    cell.periodLabel.text = "All-day"
                }
                else {
                    var periodTime: String = ""
                    // it is the startDateOfEvent
                    if(Calendar.current.dateComponents([.day, .month, .year], from: selecedDateForWeek[weekIndex]) == Calendar.current.dateComponents([.day, .month, .year], from: startDate)){
                        cell.beginTimeLabel.text = "\(stringStartDate)"
                        var startDateComponent = Calendar.current.dateComponents([.hour, .minute], from: startDate)
                        var eventHr = 23 - startDateComponent.hour!
                        var eventMin = 60 - startDateComponent.minute!
                        if(eventMin > 0) {
                            if(eventMin == 60){
                                eventHr += 1
                            }
                            if(eventHr > 0){
                                periodTime.append("\(eventHr) hr")
                            }
                            if(eventMin != 60){
                                periodTime.append(" \(eventMin) min")
                            }
                        }
                        else {
                            if(eventHr > 0){
                                periodTime.append("\(eventHr) hr")
                            }
                        }
                        cell.periodLabel.text = periodTime
                    }
                    // it is the end date of event
                    else if(Calendar.current.dateComponents([.day, .month, .year], from: selecedDateForWeek[weekIndex]) == Calendar.current.dateComponents([.day, .month, .year], from: endDate)){
                        cell.beginTimeLabel.text = "\(stringEndDate)"
                        var endDateComponent = Calendar.current.dateComponents([.hour, .minute], from: endDate)
                        var eventHr = endDateComponent.hour!
                        var eventMin = endDateComponent.minute!
                        if(eventHr > 0){
                            periodTime.append("\(eventHr) hr")
                        }
                        if(eventMin > 0) {
                            periodTime.append(" \(eventMin) min")
                        }
                        cell.periodLabel.text = periodTime
                    }
                    else {
                        cell.beginTimeLabel.text = ""
                        cell.beginTimeLabel.backgroundColor = UIColor(named: bgEventColor[weekIndex])
                        cell.periodLabel.text = "All-day"
                    }
                }
            }
            // add tabgesture
            var tabGesture = CustomTapGestureReconizerForCalendar(target: self, action: #selector(tabCalendar(sender:)))
            tabGesture.eventIdentifier = calendar.eventIdentifier
            tabGesture.ekEvent = calendar.ekEvent
            cell.addGestureRecognizer(tabGesture)
            // case the event need action
            let currentEvent = checkInvitedEvent(event: calendar)
            if(currentEvent.participantStatus != nil){
                tabGesture.participantStatus = currentEvent.participantStatus
            }
            if(currentEvent.isInvitedEventNeedAction){
                cell.exclamationmarkWidth.constant = 15
                cell.exclamationmarkHeight.constant = 15
            }
        }
        return cell
    }
    
    // style collection cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 18 = 10 (from offset) + 8 (1 offset from each collection view)
        let collectionViewHeight: CGFloat = (view.bounds.height - 18) / 7
        return CGSize(width: (view.bounds.width - CGFloat(weekLabelWidth))/4.5, height: collectionViewHeight)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // haptic feed back
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        if(showMode == "Week") {
            let location = scrollView.panGestureRecognizer.location(in: weekTableView)
            guard let indexPath = weekTableView.indexPathForRow(at: location) else {
                print("could not specify an indexpath")
                return
            }
            weekIndex = indexPath.row
            numberOfEventsAtSelectedDate = 0
            numberOfEventsAtSelectedDate = calendarData.getEvent(date: selecedDateForWeek[weekIndex]).count
            weekTableView.reloadInputViews()
        }
    }
    
    // will check velocity that user swipe the screen and assign the weekTableView indexPath to weekIndex
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if(showMode == "Week") {
            print("scrollViewWillEndDragging")
            if(velocity.x <  -2){
                showPrevWeek()
                selectedWeekTableView()
            }
            if(velocity.x > 2){
                showNextWeek()
                selectedWeekTableView()
            }
        }
    }
    
    // MARK: - Helper func to prepare data to show in weekly calendar
    func showPrevWeek(){
        selectedDate = selectedDate - (24*60*60*7)
        setHeaderLabelForWeekCalendar()
        print("user want to see prev month \(selectedDate)")
    }
    
    func showNextWeek() {
        selectedDate = selectedDate + (24*60*60*7)
        setHeaderLabelForWeekCalendar()
        print("user want to see next month \(selectedDate)")
    }
    
    func selectedWeekTableView() {
        for i in 0...6 {
            let indexPath = IndexPath(row: i, section: 0)
            weekTableView.selectRow(at: indexPath, animated: false, scrollPosition: .top)
            tableView(self.weekTableView, didSelectRowAt: indexPath)
        }
    }
    
    @objc func swipeToPrevWeek(sender: UISwipeGestureRecognizer) {
        showPrevWeek()
        weekTableView.reloadData()
    }
    @objc func swipeToNextWeek(sender: UISwipeGestureRecognizer) {
        showNextWeek()
        weekTableView.reloadData()
    }
    
    func getStringMonthShort(monthIndex: Int) -> String {
        let monthString: String = shortMonthString[monthIndex-1]
        return monthString
    }
    
    func getStringMonth(monthIndex: Int) -> String {
        let monthString: String = fullMonthString[monthIndex-1]
        return monthString
    }
    
    // MARK: - style components
    // use to style calendar that will show to user
    func setCalardar() {
        print("setCalendar")
        // check event access
        eventAccess()
        // hidden all view
        monthView.isHidden = true
        weekView.isHidden = true
        scheduleView.isHidden = true
        // style add event btn
        addBtn.layer.cornerRadius = addBtn.bounds.width/2
        addBtn.layer.shadowColor = UIColor.darkGray.cgColor
        addBtn.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        addBtn.layer.shadowOpacity = 1.0
        addBtn.layer.shadowRadius = 2.0
        // style each showMode of calendar
        switch showMode {
        case "Schedule":
            resetScheduleVariable()
            print("Schedule in setCalendar")
            headerLabel.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            scheduleView.isHidden = false
            dateToFetchSchEvents = getFirstDateOfTheMonth(selectedDate: selectedDate)
            firstDateToFetchSchEvents = getFirstDateOfTheMonth(selectedDate: selectedDate)
            print("fetch date in setCalendar \(dateToFetchSchEvents)")
            calendarData.setCalendarToShow3Months(date: dateToFetchSchEvents)
            scheduleTableView.delegate = self
            scheduleTableView.dataSource = self
            scheduleTableView.prefetchDataSource = self
        case "Week":
            print("Week")
            headerLabel.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
            weekView.isHidden = false
            // reset current selectedDate to the 00:01 AM
            selectedDate = setSelectedDateToBeginingDay(selectedDate: selectedDate)
            setHeaderLabelForWeekCalendar()
            calendarData.setCalendarToShowWeekly(date: selectedDate)
            // delegate to get data for week
            weekTableView.delegate = self
            weekTableView.dataSource = self
        default:
            print("month")
            headerLabel.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            monthView.isHidden = false
            // delegate to get data for month
            monthView.delegate = self
            monthView.dataSource = self
            monthView.calendarWeekdayView.backgroundColor = UIColor(named: "workBlue")
            self.monthView.appearance.separators = .interRows
            monthView.appearance.weekdayFont = UIFont.boldSystemFont(ofSize: FSCalendarStandardWeekdayTextSize)
            monthView.appearance.titleFont = UIFont.boldSystemFont(ofSize: 13)
            // register cell
            monthView.register(FSCalendarCell.self, forCellReuseIdentifier: "CellEmpty")
            monthView.register(FSCalendarCell.self, forCellReuseIdentifier: "CellWithPlan")
        }
    }
    
    func resetScheduleVariable(){
        scheduleEvents = []
        scheduleEventsNumber = 0
        scheduleDate = []
        scheduleRowIndex = 0
        firstLunchRowIndex = 0
        firstLunch = true
    }
    
    func setSelectedDateToBeginingDay(selectedDate: Date) -> Date{
        // get first date of the week
        let weekDay = Calendar.current.component(.weekday, from: selectedDate)
        var firstDateOfTheWeek: Date = Calendar.current.date(byAdding: .day, value: -weekDay + 1, to: selectedDate)!
        let day = Calendar.current.component(.day, from: firstDateOfTheWeek)
        let month = Calendar.current.component(.month, from: firstDateOfTheWeek)
        let year = Calendar.current.component(.year, from: firstDateOfTheWeek)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        var resetDate = formatter.date(from: "\(year)/\(month)/\(day) 00:00")!
        return resetDate
    }
    
    // MARK: - Check invitation
    // func that will use to check that event has invitation or not
    func checkInvitedEvent(event: CalendarModel) -> InvitedEventModel {
        var invitedEventModel = InvitedEventModel()
        // case the event need action
        if(event.hasAttendees) {
            if(event.attendees != nil){
                var numberOfAttendees: Int = event.attendees!.count
                for j in 0..<numberOfAttendees {
                    var email = event.attendees![j].url.absoluteString.replacingOccurrences(of: "mailto:", with: "")
                    if(event.calendar.title == email){
                        invitedEventModel.participantStatus = event.attendees![j].participantStatus.rawValue
                    }
                    if((event.calendar.title == email) && (event.attendees![j].participantStatus.rawValue == 1)){
                        invitedEventModel.isInvitedEventNeedAction = true
                    }
                }
            }
        }
        return invitedEventModel
    }
    // MARK: - Helper func to prepare data to show in monthly calendar
    func prepareDataToShowInMonthlyCalendar(firstDateOfMonth: Date) {
        print("prepareDataToShowInMonthlyCalendar")
        let lock = NSLock()
        let lock1 = NSLock()
        lock.lock()
        // reset selectedEventsMonthCalendar to empty
        selectedEventsMonthCalendar.removeAll()
        for i in 0..<42 {
            selectedEventsMonthCalendar.append(SelectedEventsMonthCalendar(date: firstDateOfMonth, eventsNumber: 0))
        }
        // get the first day of the month
        var firstDayInMonthlyCalendar: Date = firstDateOfMonth
        // if firstDate of the month is Sunday the firstDate will show in th second row
        var firstWeekDay = Calendar.current.component(.weekday, from: firstDateOfMonth)
        //print("firstDayInMonthlyCalendar: \(firstDayInMonthlyCalendar)")
        // Sunday
        if(firstWeekDay == 1) {
            firstDayInMonthlyCalendar = Calendar.current.date(byAdding: .day, value: -7, to: firstDateOfMonth)!
        }
        else {
            firstDayInMonthlyCalendar = Calendar.current.date(byAdding: .day, value: 1 - firstWeekDay, to: firstDateOfMonth)!
        }
        var curDate: Date = firstDayInMonthlyCalendar
        // index that count that will use to count the curDate in 42 days
        var monthIndex: Int = 0
        for i in 0..<6 {
            // will use to record the previous calendar
            var eventId = [String](repeating: "", count: 35)
            for j in 1...7 {
                // load calendar
                lock1.lock()
                var eventsData = calendarData.getEvent(date: curDate)
                lock1.unlock()
                var curWeekDay = Calendar.current.component(.weekday, from: curDate)
                //print("curDate: \(curDate), monthIndex: \(monthIndex)")
                selectedEventsMonthCalendar[monthIndex].date = curDate
                var eventsNumber = eventsData.count
                selectedEventsMonthCalendar[monthIndex].eventsNumber = eventsNumber
                if(eventsNumber > 5) {
                    eventsNumber = 5
                }
                switch curWeekDay {
                    // Sunday
                case 1:
                    for k in 0..<eventsNumber {
                        selectedEventsMonthCalendar[monthIndex].calendar[k] = eventsData[k]
                        eventId[k] = eventsData[k].eventIdentifier
                        selectedEventsMonthCalendar[monthIndex].remark[k] = getRemarkCalendar(curDate: curDate, curWeekDay: curWeekDay, eventStartDate: eventsData[k].startDate, eventEndDate: eventsData[k].endDate)
                    }
                    break
                default:
                    //print("Not sunday: \(curWeekDay)")
                    var dayIndex: Int = 1
                    var tmpIndex: Int = 1
                    for k in 0..<eventsNumber {
                        var remark = getRemarkCalendar(curDate: curDate, curWeekDay: curWeekDay, eventStartDate: eventsData[k].startDate, eventEndDate: eventsData[k].endDate)
                        // several days of event with NOT start day
                        tmpIndex = dayIndex
                        if((remark == 3) || (remark == 4)) {
                            // prev day have the same event
                            if(eventId[((j-2) * 5) + tmpIndex - 1] == eventsData[k].eventIdentifier) {
                                dayIndex += 1
                            }
                            else {
                                while ((eventId[((j-2) * 5) + tmpIndex - 1] != eventsData[k].eventIdentifier)&&(tmpIndex != 4)) {
                                    tmpIndex += 1
                                }
                            }
                        }
                        // several days of event with the START day
                        else {
                            if(remark != 0){
                                while(eventId[((j-1) * 5) + tmpIndex - 1] != "")&&(tmpIndex != 4){
                                    tmpIndex += 1
                                }
                                dayIndex += 1
                            }
                        }
                        selectedEventsMonthCalendar[monthIndex].calendar[tmpIndex-1] = eventsData[k]
                        selectedEventsMonthCalendar[monthIndex].remark[tmpIndex-1] = remark
                        eventId[((j-1) * 5) + tmpIndex - 1] = eventsData[k].eventIdentifier
                    }
                    break
                }
                curDate = Calendar.current.date(byAdding: .day, value: 1, to: curDate)!
                monthIndex += 1
            }
        }
        lock.unlock()
    }
    
    func getRemarkCalendar(curDate: Date, curWeekDay: Int, eventStartDate: Date, eventEndDate: Date ) -> Int {
        // several days of event with the START day
        var endEvent = Calendar.current.dateComponents([.hour], from: curDate, to: eventEndDate)
        var hrToEndEvent = endEvent.hour
        var hrToEndWeek = calendarData.getHrToEndWeek(currDay: curWeekDay)
        var remark = 99
        // one day event
        if(calendarData.isOneDayEvent(startDate: eventStartDate, endDate: eventEndDate)){
            remark = 5
        }
        // several day event
        else {
            if(calendarData.isDateOfEventStartDate(currDate: curDate, eventStartDate: eventStartDate)){
                // several days of event with the START day that will NOT end in this week
                if(calendarData.isEndDateLongerThanRemainCell(hrToEndEvent: hrToEndEvent!, hrToEndWeek: hrToEndWeek)){
                    remark = 1
                }
                // several days of event with the START day that will end in this week
                else {
                    remark = 2
                }
            }
            // several days of event with NOT start day
            else {
                // several days of event with NOT start day that will NOT end in this week
                if(calendarData.isEndDateLongerThanRemainCell(hrToEndEvent: hrToEndEvent!, hrToEndWeek: hrToEndWeek)){
                    remark = 3
                }
                // several days of event with NOT start day that will end in this week
                else {
                    remark = 4
                }
            }
        }
        return remark
    }
    
    func getPositionInMonthlyCalendar(cellDate: Date) -> Int{
        // get the first day of the month
        var firstDayInMonthlyCalendar: Date = selectedDate
        // if firstDate of the month is Sunday the firstDate will show in th second row
        var firstWeekDay = Calendar.current.component(.weekday, from: selectedDate)
        if(firstWeekDay == 1) {
            firstDayInMonthlyCalendar = Calendar.current.date(byAdding: .day, value: -7, to: firstDayInMonthlyCalendar)!
        }
        else {
            firstDayInMonthlyCalendar = Calendar.current.date(byAdding: .day, value: 1 - firstWeekDay, to: firstDayInMonthlyCalendar)!
        }
        var diffDay = Calendar.current.dateComponents([.day], from: firstDayInMonthlyCalendar, to: cellDate)
        var index: Int = 0
        index = diffDay.day!
        return index
    }
    
    // MARK: - helper for week
    // assign month header and
    func setHeaderLabelForWeekCalendar(){
        print("setHeaderLabelForWeekCalendar")
        var weekDay = Calendar.current.component(.weekday, from: selectedDate)
        var firstDateInTheWeek: Date = selectedDate
        firstDateInTheWeek = Calendar.current.date(byAdding: .day, value: 1 - weekDay, to: firstDateInTheWeek)!
        var day1 = Calendar.current.component(.day, from: firstDateInTheWeek)
        var month1 = Calendar.current.component(.month, from: firstDateInTheWeek)
        var lastDateInTheWeek: Date = firstDateInTheWeek
        lastDateInTheWeek = Calendar.current.date(byAdding: .day, value: 6, to: lastDateInTheWeek)!
        var day7 = Calendar.current.component(.day, from: lastDateInTheWeek)
        var month7 = Calendar.current.component(.month, from: lastDateInTheWeek)
        var year = Calendar.current.component(.year, from: lastDateInTheWeek)
        if(month1 == month7){
            var monthString = getStringMonthShort(monthIndex: month1)
            headerLabel.setTitle("\(monthString) \(day1) - \(day7), \(year)", for: .normal)
        }
        else {
            var monthString1 = getStringMonthShort(monthIndex: month1)
            var monthString7 = getStringMonthShort(monthIndex: month7)
            headerLabel.setTitle("\(monthString1) \(day1) - \(monthString7) \(day7), \(year)", for: .normal)
        }
        calendarData.setCalendarToShowWeekly(date: firstDateInTheWeek)
        setSelecedDateForWeek(firstDateInTheWeek: firstDateInTheWeek)
    }
    
    // to assign date to show for Week
    func setSelecedDateForWeek(firstDateInTheWeek: Date){
        selecedDateForWeek.removeAll()
        var date: Date = firstDateInTheWeek
        print(date)
        selecedDateForWeek.append(date)
        for i in 0...5 {
            date = Calendar.current.date(byAdding: .day, value: 1, to: date)!
            print(date)
            selecedDateForWeek.append(date)
        }
    }
    
    // MARK: - hekper for schedule
    func getFirstDateOfTheMonth(selectedDate: Date) -> Date{
        let day = 1
        let month = Calendar.current.component(.month, from: selectedDate)
        let year = Calendar.current.component(.year, from: selectedDate)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        var getFirstDateOfTheMonth = formatter.date(from: "\(year)/\(month)/\(day) 00:00")!
        return getFirstDateOfTheMonth
    }
    
    // func that will use to load data next 3 months when tableView reach to the bottom
    func loadNextDataForScheduleMode(){
        print("loadNextDataForScheduleMode dateToFetchSchEvents: \(dateToFetchSchEvents)")
        print("current time \(Date())")
        calendarData.setCalendarToShow3Months(date: dateToFetchSchEvents)
        var onedayBeforeSelectedDate: Date = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate)!
        
        for i in 0...2 {
            scheduleEvents.append(ScheduleEvents(type: "header", event: nil))
            scheduleDate.append(dateToFetchSchEvents)
            scheduleEventsNumber += 1
            if(firstLunch && (dateToFetchSchEvents < onedayBeforeSelectedDate)){
                firstLunchRowIndex += 1
            }
            
            var range = Calendar.current.range(of: .day, in: .month, for: dateToFetchSchEvents)
            var numDays = range!.count
            
            
            for j in 0..<numDays {
                let events = calendarData.getEvent(date: dateToFetchSchEvents)
                scheduleEventsNumber += events.count
                if((dateToFetchSchEvents < onedayBeforeSelectedDate) && firstLunch){
                    firstLunchRowIndex += events.count
                }
                for k in 0..<events.count {
                    if(k == 0) {
                        scheduleEvents.append(ScheduleEvents(type: "eventFirstDate", event: events[k]))
                    } else {
                        scheduleEvents.append(ScheduleEvents(type: "event", event: events[k]))
                    }
                    scheduleDate.append(dateToFetchSchEvents)
                }
                dateToFetchSchEvents = Calendar.current.date(byAdding: .day, value: 1, to: dateToFetchSchEvents)!
            }
            
        }
        print("event number \(scheduleEventsNumber)")
    }
    
    // func that will use to load data prev 3 months when tableView reach to the top
    func loadPrevDataForScheduleMode(){
        print("loadPrevDataForScheduleMode")
        var date = firstDateToFetchSchEvents
        firstDateToFetchSchEvents = Calendar.current.date(byAdding: .month, value: -3, to: date)!
        date = firstDateToFetchSchEvents
        calendarData.setCalendarToShow3Months(date: firstDateToFetchSchEvents)
        var tmpScheduleEvents: [ScheduleEvents] = []
        var tmpScheduleDate: [Date] = []
        var tmpScheduleEventsNumber: Int = 0
        for i in 0...2 {
            tmpScheduleEvents.append(ScheduleEvents(type: "header", event: nil))
            tmpScheduleDate.append(date)
            tmpScheduleEventsNumber += 1
            var range = Calendar.current.range(of: .day, in: .month, for: date)
            var numDays = range!.count
            for j in 0..<numDays {
                let events = calendarData.getEvent(date: date)
                tmpScheduleEventsNumber += events.count
                for k in 0..<events.count {
                    if(k == 0) {
                        tmpScheduleEvents.append(ScheduleEvents(type: "eventFirstDate", event: events[k]))
                    } else {
                        tmpScheduleEvents.append(ScheduleEvents(type: "event", event: events[k]))
                    }
                    tmpScheduleDate.append(date)
                }
                date = Calendar.current.date(byAdding: .day, value: 1, to: date)!
            }
        }
        scheduleEventsNumber = tmpScheduleEventsNumber + scheduleEventsNumber
        print("tmpScheduleEventsNumber \(tmpScheduleEventsNumber)")
        print("scheduleEventsNumber \(scheduleEventsNumber)")
        scheduleEvents.insert(contentsOf: tmpScheduleEvents, at: 0)
        scheduleDate.insert(contentsOf: tmpScheduleDate, at: 0)
        scheduleTableView.reloadData()
        let indexPath = IndexPath(row: tmpScheduleEventsNumber + 1, section: 0)
        self.scheduleTableView.scrollToRow(at: indexPath, at: .top, animated: false)
    }
    
    // MARK: - prepare seque
    @IBAction func unwindBackToCalendarView(_ segue: UIStoryboardSegue) {
        print("go back to calendarVC from menu")
        print("date to fetch \(dateToFetchSchEvents)")
        
        // reload data **** this might need to change if somthing wrong
        //viewDidLoad()
    }
    
    // func to prepare variable when perform segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "goToMenuCalendarSegue") {
            if(showMode == "Month") && (swipe < 2){
                print("pressedListTabbar")
                selectedDate = loadedDate
            }
            let destinationVC = segue.destination as! MenuCalendarViewController
            destinationVC.showMode = showMode
            
        }
        
        else if(segue.identifier == "goToSelectedCalendarSegue"){
            let destinationVC = segue.destination as! SelectedCalendarViewController
            if(eventIdentifier != nil){
                destinationVC.eventIdentifier = eventIdentifier
                destinationVC.ekEvent = ekEvent
                if(participantStatus != nil){
                    destinationVC.participantStatus = participantStatus
                }
            }
        }
    }
    // MARK: - action function
    @IBAction func pressedListTabbar(_ sender: Any) {
        tapBtn()
        
        performSegue(withIdentifier: "goToMenuCalendarSegue", sender: self)
        
        //monthView.scope = .week
        //        handleMenuToggle()
    }
    
    @IBAction func pressedTaskTabbar(_ sender: Any) {
    }
    
    @IBAction func pressedSearchTabbar(_ sender: Any) {
        //        performSegue(withIdentifier: "editTestSegue", sender: self)
    }
    
    @IBAction func pressedTodayTabbar(_ sender: Any) {
        tapBtn()
        swipe = 0
        print("pressedTodayTabbar")
        selectedDate = Date()
        loadedDate = selectedDate
        switch showMode {
        case "Schedule":
            print("Schedule need to add func")
            let indexPath = IndexPath(row: 5, section: 0)
            self.scheduleTableView.scrollToRow(at: indexPath, at: .top, animated: true)
        case "Week":
            print("Week")
            // reset current selectedDate to current date
            firstLunch = true
            selectedDate = setSelectedDateToBeginingDay(selectedDate: selectedDate)
            setHeaderLabelForWeekCalendar()
            calendarData.setCalendarToShowWeekly(date: selectedDate)
            weekTableView.reloadData()
        default:
            print("Month")
            firstLunch = true
            monthView.allowsSelection = true
            monthView.select(monthView.today)
            monthView.allowsSelection = false
        }
    }
    
    @IBAction func pressedAddBtn(_ sender: Any) {
    }
    
    // use to show selected calendar that will perform to editSegue
    @objc func tabCalendar(sender: CustomTapGestureReconizerForCalendar){
        tapBtn()
        print("tabCalendar")
        if(sender.participantStatus != nil){
            participantStatus = sender.participantStatus!
        }
        eventIdentifier = sender.eventIdentifier
        ekEvent = sender.ekEvent
        performSegue(withIdentifier: "goToSelectedCalendarSegue", sender: self)
    }
    
    // use to make haptic when user click botton
    func tapBtn(){
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    @IBAction func pressedUpdateSetting(_ sender: Any) {
        // used to open settning
        UIApplication.shared.open(URL.init(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
    }
    
    @IBAction func pressedCancelSetting(_ sender: Any) {
        updateSettingView.isHidden = true
        addBtn.isHidden = false
    }
}
