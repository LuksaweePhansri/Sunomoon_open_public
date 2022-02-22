//
//  DailyHoroscopeViewController.swift
//  Sunomoon
//
//  Created by Luksawee Phansri on 7/11/21.
//

import Foundation
import UIKit
class DailyHoroscopeViewController: UIViewController {
    @IBOutlet var arrayTotalBtn: [UIButton]!
    
    var orderTarot: [Int] = [
        0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
        11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
        21
    ]
    var tarotCardNumber: Int = 0
    
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
        orderTarot.shuffle()
        for i in 0...11 {
            arrayTotalBtn[i].tag = orderTarot[i]
            print(orderTarot[i])
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Lock scene orientation
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
    }
    
    @IBAction func pressedBtn(_ sender: UIButton) {
        print(sender.tag)
        tarotCardNumber = sender.tag
        self.performSegue(withIdentifier: "goSelectedTarotViewControllerSegue", sender: self)
    }
    
    // MARK: - Prepare segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "goSelectedTarotViewControllerSegue"){
            let destinationVC = segue.destination as! SelectedTarotViewController
            destinationVC.tarotCardNumber = tarotCardNumber
            
        }
    }
}
