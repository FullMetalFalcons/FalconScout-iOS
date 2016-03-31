//
//  ViewControllerPicker.swift
//  Scouting
//
//  Created by Alex DeMeo on 3/30/16.
//  Copyright © 2016 Alex DeMeo. All rights reserved.
//

import UIKit

class ViewControllerPicker: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var pickerView: UIPickerView!
    
    var items: [String]!
    
    var retValue: String? = nil
    var completion: (() -> ())!
    
    func initialize(items i: [String], title: String, completion: () -> ()) {
        self.items = i
        self.titleLabel.text = title
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        self.completion = completion
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.items.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.items[row]
    }
    
    @IBAction func close() {
        retValue = self.items[self.pickerView.selectedRowInComponent(0)]
        self.dismissViewControllerAnimated(true, completion: {
            self.completion()
        })
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}