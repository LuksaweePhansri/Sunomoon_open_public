//
//  SelectAlarmMissionViewController.swift
//  Sunomoon
//
//  Created by Luksawee Phansri on 6/15/21.
//

import Foundation
import UIKit
class SelectAlarmMissionViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    var selectedRow: Int = 0
    var numbers: [String] = []
    @IBOutlet weak var mission: UILabel!
    @IBOutlet weak var pickerLabel: UILabel!
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var missionLevelLabel: UILabel!
    @IBOutlet weak var level: UILabel!
    @IBOutlet weak var easy: UILabel!
    @IBOutlet weak var normal: UILabel!
    @IBOutlet weak var hard: UILabel!
    @IBOutlet weak var sliderLevel: UISlider!
    
    var selectedMission: String?
    var selectedMissionNumber: Int?
    var selectedMissionLevel: String?
    // Use to not allow user to get the auto rotation
    override var shouldAutorotate: Bool {
        return false
    }
    
    override func viewDidLoad() {
        print("SelectAlarmMissionVC")
        // make app to have light theme
        overrideUserInterfaceStyle = .light
        // lock to portrait
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        super.viewDidLoad()
        picker.dataSource = self
        picker.delegate = self
        picker.layer.cornerRadius = picker.layer.bounds.width/2
        mission.text = selectedMission
        level.text = selectedMissionLevel
        for i in 0..<10 {
            if((selectedMission == "Squat") || (selectedMission == "Shake")) {
                numbers.append(String((i+1)*5))
            }
            if((selectedMission == "Memo") || (selectedMission == "Math") || (selectedMission == "Typing")){
                numbers.append(String(i+1))
            }
        }
        
        switch selectedMission {
        case "Squat":
            hideLevel()
            pickerLabel.text = "Number of " + selectedMission! + "s to stop alarm"
        case "Typing":
            hideLevel()
            pickerLabel.text = "Number of Typing sentences to stop alarm"
        case "Shake":
            missionLevelLabel.text = "Shake sensitivity"
            pickerLabel.text = "Number of " + selectedMission! + "s to stop alarm"
        case "Memo":
            missionLevelLabel.text = "Difficulty"
            pickerLabel.text = "Number of Memo games to stop alarm"
        case "Math":
            missionLevelLabel.text = "Difficulty"
            pickerLabel.text = "Number of Questions to stop alarm"
        default:
            missionLevelLabel.text = "Shake sensitivity"
        }
        
        selectedViewDidLoadRow()
        switch selectedMissionLevel {
        case "easy":
            sliderLevel.value = 0
        case "hard":
            sliderLevel.value = 2
        default:
            sliderLevel.value = 1
        }
    }
    
    func hideLevel(){
        missionLevelLabel.isHidden = true
        level.isHidden = true
        easy.isHidden = true
        normal.isHidden = true
        hard.isHidden = true
        sliderLevel.isHidden = true
    }
    
    func selectedViewDidLoadRow() {
        if((selectedMission == "Squat") || (selectedMission == "Shake")){
            selectedRow = selectedMissionNumber!/5 - 1
        }
        else {
            selectedRow = selectedMissionNumber! - 1
        }
        picker.selectRow(selectedRow, inComponent: 0, animated: true)
    }
    
    @IBAction func slidedSliderLevel(_ sender: Any) {
        // make sliderLevel to not continue
        sliderLevel.value = roundf(sliderLevel.value)
        switch sliderLevel.value {
        case 0:
            level.text = "easy"
        case 1:
            level.text = "normal"
        case 2:
            level.text = "hard"
        default:
            level.text = "normal"
        }
        selectedMissionLevel = level.text
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return numbers.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return numbers[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if((selectedMission == "Squat") || (selectedMission == "Shake")) {
            selectedMissionNumber = (row + 1) * 5
        }
        if((selectedMission == "Typing") || (selectedMission == "Memo") || (selectedMission == "Math")){
            selectedMissionNumber = (row + 1)
        }
        print("mission number: \(selectedMissionNumber)")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "saveSelectedAlarmMissionSegue") {
            let destinationVC = segue.destination as! AddEditAlarmViewController
            destinationVC.missionNumber = selectedMissionNumber!
            destinationVC.missionLevel = selectedMissionLevel!
        }
    }

    @IBAction func pressedSelectBtn(_ sender: Any) {
        performSegue(withIdentifier: "saveSelectedAlarmMissionSegue", sender: self)
    }
}
