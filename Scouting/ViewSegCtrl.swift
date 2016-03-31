//
//  ViewSegmentedControl.swift
//  InterfaceConstruction
//
//  Created by Alex DeMeo on 1/6/16.
//  Copyright © 2016 Alex DeMeo. All rights reserved.
//

import UIKit

class ViewSegCtrl: CustomView {
    var label: UILabel!
    var segCtrl: UISegmentedControl!
    
    init(title: String, key: String, elements: [String]) {
        super.init(title: title, key: key)
        ViewControllerScout.arraySegCtrlViews.append(self)
        self.label = UILabel(frame: CGRect(x: self.frame.minX, y: -15, width: self.frame.width, height: self.frame.height))
        self.label.text = title
        self.label.textAlignment = NSTextAlignment.Center
        self.label.font = UIFont.systemFontOfSize(CustomView.textSize)
        self.addSubview(self.label)
        
        self.segCtrl = UISegmentedControl(items: elements)
        self.segCtrl.frame = CGRect(x: self.frame.minX + 7.5, y: self.frame.height * (2/5), width: self.frame.width - 15, height: self.frame.height * (4/7))
        self.addSubview(self.segCtrl)
        self.segCtrl.addTarget(self, action: #selector(ViewSegCtrl.changed(_:)), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func changed(segCtrl: UISegmentedControl) {
        KEYS[self.key] = segCtrl.titleForSegmentAtIndex(segCtrl.selectedSegmentIndex)!
        print("For key: \(self.key), value is: \(segCtrl.titleForSegmentAtIndex(segCtrl.selectedSegmentIndex)!)")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ViewSegCtrl {
    @objc func segTeamColorChanged(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            ViewControllerScout.instance.setColor(UIColor.blueColor())
            ViewControllerScout.instance.setViewColor(CustomView.colorBlueForView)
            KEYS[K_TEAM_COLOR] = "Blue"
        case 1:
            ViewControllerScout.instance.setColor(UIColor.redColor())
            ViewControllerScout.instance.setViewColor(CustomView.colorRedForView)
            KEYS[K_TEAM_COLOR] = "Red"
        default: return
        }
    }
}