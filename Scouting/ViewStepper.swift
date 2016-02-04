//
//  ViewStepper.swift
//  InterfaceConstruction
//
//  Created by Alex DeMeo on 1/6/16.
//  Copyright © 2016 Alex DeMeo. All rights reserved.
//

import UIKit

class ViewStepper: CustomView {
    var label: UILabel!
    var stepper: UIStepper!
    
    init(title: String, key: String, lowerBound: Int, upperBound: Int) {
        super.init(title: title, key: key)
        self.stepper = UIStepper(frame: CGRect(x: self.frame.maxX - 105, y: 5, width: 100, height: self.frame.height * (1/2)))
        self.stepper.minimumValue = Double(lowerBound)
        self.stepper.maximumValue = Double(upperBound)
        self.addSubview(self.stepper)

        ViewControllerMain.arrayStepperViews.append(self)
        self.label = UILabel(frame: CGRect(x: self.frame.minX + 5, y: 5, width: self.frame.width * (1/2), height: self.frame.height))
        self.label.font = UIFont.systemFontOfSize(CustomView.textSize)
        self.label.text = "\(title): \(Int(stepper.value))"
        self.addSubview(self.label)
        
        self.stepper.addTarget(self, action: Selector("changed:"), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func changed(stepper: UIStepper) {
        KEYS[self.key] = Int(stepper.value)
        self.label.text = "\(title): \(Int(stepper.value))"
        print("For key: \(self.key), value is: \(Int(stepper.value))")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

