//
//  SelectedTarotViewController.swift
//  Sunomoon
//
//  Created by Luksawee Phansri on 7/11/21.
//
import Foundation
import UIKit
class SelectedTarotViewController: UIViewController {
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var tarotCardNameLabel: UILabel!
    @IBOutlet weak var tarotCardMeaningLabel: UILabel!
    @IBOutlet weak var tarotCardImg: UIImageView!
    @IBOutlet weak var luckyNumberLabel: UILabel!
    
    var tarot = TarotData()
    var set: Int = 1
    var tarotCardNumber: Int = 0
    var tarotCard: String = "The Fool"
    var tarotMeaning: String = "Expect the unexpected. Don't even expect that much. Today could be a wild ride, and you may instigate some of it in the spirit of fun, suggests the Fool card. Play it safe and stay out of trouble if you can, but it could be hard at times. Don't fret over any little mistakes today. By tonight or at least tomorrow, it may be hard to tell who made them if anyone even recalls them."
    var tarotCardPic: String = "TheFool"
    var numberArray: [Int] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9,
                              10, 11, 12, 13, 14, 15, 16, 17, 18, 19,
                              20, 21, 22, 23, 24, 25, 26, 27, 28, 29,
                              30, 31, 32, 33, 34, 35, 36, 37, 38, 39,
                              40, 41, 42, 43, 44, 45, 46, 47, 48, 49,
                              50, 51, 52, 53, 54, 55, 56, 57, 58, 59,
                              60, 61, 62, 63, 64, 65, 66, 67, 68, 69,
                              70, 71, 72, 73, 74, 75, 76, 77, 78, 79,
                              80, 81, 82, 83, 84, 85, 86, 87, 88, 89,
                              90, 91, 92, 93, 94, 95, 96, 97, 98, 99]
    
    @IBOutlet weak var manualTestBtn: UIButton!
    
    // Use to not allow user to get the auto rotation
    override var shouldAutorotate: Bool {
        return false
    }
    
    override func viewDidLoad() {
        // make app to have light theme
        overrideUserInterfaceStyle = .light
        // lock to portrait
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        super.viewDidLoad()
        setBackgroundComponents()
        set = Int.random(in: 1...2)
        
//        // manual test to check grammar
//        set = 1
//        tarotCardNumber = 0
        
        // random luckky number
        numberArray.shuffle()
        loadHoroscopeData()
        setBackgroundComponents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Lock scene orientation
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
    }
    
//    @IBAction func pressedManualBtn(_ sender: Any) {
//        tarotCardNumber += 1
//        loadHoroscopeData()
//        setBackgroundComponents()
//    }
    
    @IBAction func pressedBackBtn(_ sender: Any) {
        SelectedScene.instance.goToDailyAlarmInfoVC()
    }
    
    @IBAction func pressedCloseBtn(_ sender: Any) {
        SelectedScene.instance.goToTodayVC()
    }
    
    //MARK: - set components
    func setBackgroundComponents() {
        backBtn.layer.cornerRadius = backBtn.layer.bounds.width/2
        closeBtn.layer.cornerRadius = closeBtn.layer.bounds.width/2
        tarotCardNameLabel.text = tarotCard
        tarotCardMeaningLabel.text = tarotMeaning
        tarotCardImg.image = UIImage(named: tarotCardPic)
        luckyNumberLabel.text = "Lucky number: \(numberArray[0]), \(numberArray[1]), and \(numberArray[2])"
    }
    
    func loadHoroscopeData(){
        tarotCard = tarot.getTarotCard(set: set, tarotCardNumber: tarotCardNumber)
        tarotMeaning = tarot.getTarotMeaning(set: set, tarotCardNumber: tarotCardNumber)
        tarotCardPic = tarot.getTarotCardPic(set: set, tarotCardNumber: tarotCardNumber)
    }
}
