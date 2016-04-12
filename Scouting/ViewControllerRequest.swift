//
//  ViewControllerRequest.swift
//  Scouting
//
//  Created by Alex DeMeo on 2/22/16.
//  Copyright © 2016 Alex DeMeo. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewControllerRequest: UIViewController, UITextFieldDelegate {
    internal static var instance: ViewControllerRequest!
    
    @IBOutlet var textFields: [UITextField]!
    @IBOutlet var loadingSpinner: UIActivityIndicatorView!
    
    var currentTextFieldIndex = -1
    var gestureCloseKeyboard: UITapGestureRecognizer!
    var requestTeamsStr = "raw;;key;;sign;;value"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadingSpinner.hidden = true
        for textField in textFields {
            textField.delegate = self
        }
        textFields[0].keyboardType = UIKeyboardType.NumberPad
        textFields[4].keyboardType = UIKeyboardType.DecimalPad
        
        self.gestureCloseKeyboard = UITapGestureRecognizer(target: self, action: #selector(ViewControllerRequest.closeKeyboard(_:)))
        self.view.addGestureRecognizer(self.gestureCloseKeyboard)
        for key in ViewControllerScout.allPotentialKeys {
            print("HAS KEY: \(key)")
            let pkey = self.toPrettyKey(key)
            ViewControllerScout.prettyToKey[pkey] = key
            ViewControllerScout.allPrettyKeys.append(pkey)
        }
    }
    
    private func toPrettyKey(key: String) -> String {
        var pts = key.componentsSeparatedByString("_")
        pts[0] = pts[0].uppercaseString
        for i in 1..<pts.count {
            pts[i] = pts[i].capitalizedString
        }
        var f = ""
        for pt in pts {
            f += " \(pt)"
        }
        return f
    }
    
    func showInfoWithStringData(data: String) {
        self.loadingSpinner.stopAnimating()
        self.loadingSpinner.hidden = true
        
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

    
    @IBAction func btnSearchTeamPressed(sender: UIButton) {
        self.loadingSpinner.hidden = false
        self.loadingSpinner.startAnimating()
        let teamNum = textFields[0].text!
        let requestStr = "n::\(teamNum)"
        print("TEAM string: \(requestStr)")
        ViewControllerMain.instance.peripheralManager.updateValue(requestStr.dataUsingEncoding(NSUTF8StringEncoding)!, forCharacteristic: CHARACTERISTIC_DB, onSubscribedCentrals: nil)
        
    }
    
    @IBAction func btnSearchInfoPressed(sender: UIButton) {
        let p1 = textFields[1].text == "Average" ? "avg" : "raw"
        let p2 = ViewControllerScout.prettyToKey[textFields[2].text!]!
        let p3 = textFields[3].text!
        let p4 = textFields[4].text!
        let teamsInfo = "\(p1);;\(p2);;\(p3);;\(p4)"
        let requestStr = "i::\(teamsInfo)"
        print("INFO string: \(requestStr)")
        ViewControllerMain.instance.peripheralManager.updateValue(requestStr.dataUsingEncoding(NSUTF8StringEncoding)!, forCharacteristic: CHARACTERISTIC_DB, onSubscribedCentrals: nil)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        switch textField {
        case textFields[0]:
            self.currentTextFieldIndex = 0
        case textFields[1]:
            self.currentTextFieldIndex = 1
            self.getPickerChoice(["Raw value", "Average"], title: "Which type of data to look at?", completion: {
                val in
                self.textFields[1].text = val
            })
        case textFields[2]:
            self.currentTextFieldIndex = 2
            self.getPickerChoice(ViewControllerScout.allPrettyKeys, title: "Select key", completion: {
                val in
                self.textFields[2].text = val
            })
        case textFields[3]:
            self.currentTextFieldIndex = 3
            self.getPickerChoice([">", "<", "≥", "≤", "="], title: "Select the operator for comparison", completion: {
                val in
                self.textFields[3].text = val
            })
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
    
    func getPickerChoice(items: [String], title: String, completion: String -> ()) {
        self.view.endEditing(true)
        let pickerVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Picker") as! ViewControllerPicker
        self.presentViewController(pickerVC, animated: true, completion: {
            pickerVC.initialize(items: items, title: title, completion: {
                completion(pickerVC.retValue!)
            })
        })
    }
    
    func reinstantiate() {
        ViewControllerRequest.instance = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Request") as! ViewControllerRequest
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
