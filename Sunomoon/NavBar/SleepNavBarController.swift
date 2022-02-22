//
//  SleepNavBarController.swift
//  Sunomoon
//
//  Created by Luksawee Phansri on 1/21/21.
//

import UIKit

class SleepNavBarController: UINavigationBar {
    //set NavigationBar's height
    @IBInspectable var customHeight : CGFloat = 66
    override func layoutSubviews() {
        overrideUserInterfaceStyle = .light
        super.layoutSubviews()
        //print(self.subviews)
        for subview in self.subviews {
            let stringFromClass = NSStringFromClass(subview.classForCoder)
            if stringFromClass.contains("UINavigationBarContentView") {
                //Set Center Y
                let centerY = (customHeight - subview.frame.height) / 2.0
                subview.backgroundColor = UIColor(named: "skyColor")
                subview.frame = CGRect(x: 0, y: centerY, width: self.frame.width, height: customHeight)
                subview.sizeToFit()
            }
        }
    }
    
    
}
