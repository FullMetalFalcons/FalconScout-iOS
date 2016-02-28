//
//  ViewControllerRequest.swift
//  Scouting
//
//  Created by Alex DeMeo on 2/22/16.
//  Copyright © 2016 Alex DeMeo. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewControllerRequest: UIViewController, UIPickerViewDelegate, UITextFieldDelegate,UIPickerViewDataSource {
    internal static var instance: ViewControllerRequest!
    
    @IBOutlet var textFields: [UITextField]!
    @IBOutlet var loadingSpinner: UIActivityIndicatorView!
    
    var currentTextFieldIndex = -1
    var gestureCloseKeyboard: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadingSpinner.hidden = true
        for textField in textFields {
            textField.delegate = self
        }
        textFields[0].keyboardType = UIKeyboardType.NumberPad
        textFields[4].keyboardType = UIKeyboardType.DecimalPad
        
        self.gestureCloseKeyboard = UITapGestureRecognizer(target: self, action: "closeKeyboard:")
        self.view.addGestureRecognizer(self.gestureCloseKeyboard)
    }
    
    func showSummaryWithStringData(data: String) {
        self.loadingSpinner.stopAnimating()
        self.loadingSpinner.hidden = true
        let teamDict = NSMutableDictionary()
        do {
            let regex = try NSRegularExpression(pattern: "\\[(.*?)\\]", options: NSRegularExpressionOptions.AllowCommentsAndWhitespace)
            
            let parts = regex.matchesInString(data, options: NSMatchingOptions.ReportCompletion, range: NSMakeRange(0, data.characters.count))

            let pieces: [String] = parts.map({
                result in
                (data as NSString).substringWithRange(result.range)
            })
            for var p in pieces {
                p.remove("[")
                p.remove("]")
                let s = p.componentsSeparatedByString("=")
                teamDict[s[0]] = s[1]
            }
            ViewControllerData.reinstantiate(teamDict)
            self.presentViewController(ViewControllerData.instance, animated: true, completion: {})
        } catch {
            print("Eror parsing data: \(error)")
            alert("Could not read the data the computer sent")
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        switch self.currentTextFieldIndex {
        case 1: return 2
        case 2: return 0
            //Return number of keys
        case 3: return 5
        default: return 0
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "Test"
    }
    
    @IBAction func btnSearchTeamPressed(sender: UIButton) {
        self.loadingSpinner.hidden = false
        self.loadingSpinner.startAnimating()
        ViewControllerMain.instance.peripheralManager.updateValue(textFields[0].text!.dataUsingEncoding(NSUTF8StringEncoding)!, forCharacteristic: CHARACTERISTIC_DB, onSubscribedCentrals: nil)
        
    }
    
    @IBAction func btnSearchInfoPressed(sender: UIButton) {
        
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        switch textField {
        case textFields[0]:
            self.currentTextFieldIndex = 0
        case textFields[1]:
            self.currentTextFieldIndex = 1
        case textFields[2]:
            self.currentTextFieldIndex = 2
        case textFields[3]:
            self.currentTextFieldIndex = 3
        case textFields[4]:
            self.currentTextFieldIndex = 4
        default:
            self.currentTextFieldIndex = -1
        }
    }
    
    @IBAction func btnGoBack(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.currentTextFieldIndex = -1
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func closeKeyboard(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
