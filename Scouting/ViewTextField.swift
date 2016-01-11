//
//  ViewTextField.swift
//  InterfaceConstruction
//
//  Created by Alex DeMeo on 1/6/16.
//  Copyright © 2016 Alex DeMeo. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewTextField: CustomView {
    var label: UILabel!
    var textField: UITextField!
    
    init(title: String, key: String, type: String) {
        super.init(title: title, key: key)
        ViewController.arrayTextFieldViews.append(self)
        self.label = UILabel(frame: CGRect(x: self.frame.minX + 5, y: 0, width: self.frame.width * (1/2), height: self.frame.height))
        self.label.font = UIFont.systemFontOfSize(CustomView.textSize)
        self.label.text = "\(title):"
        self.addSubview(self.label)
        
        self.textField = UITextField(frame: CGRect(x: self.frame.midX, y: 10, width: self.frame.width * (1/2) - 5, height: self.frame.height * (1/2)))
        self.textField.borderStyle = UITextBorderStyle.Bezel
        self.textField.backgroundColor = UIColor.whiteColor()
        switch type.trim() {
        case "decimal": self.textField.keyboardType = UIKeyboardType.DecimalPad
        case "normal": self.textField.keyboardType = UIKeyboardType.Default
        case "number": self.textField.keyboardType = UIKeyboardType.NumberPad
        default: break
        }
        self.addSubview(self.textField)
        self.textField.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ViewTextField: UITextFieldDelegate {
    
    func textFieldDidEndEditing(textField: UITextField) {
        switch textField {
        case ViewController.instance.txtTeamNum:
            if let teamNum = Int(textField.text!) {
                if teamNum > 9999 {
                    alert("That number is too big")
                    textField.text = ""
                } else {
                    print("team num is \(textField.text!)")
                    KEYS[K_TEAM_NUMBER] = teamNum
                }
            } else {
                alert("That is not a number")
                textField.text = ""
            }
        case ViewController.instance.txtMatchNum:
            if let matchNum = Int(textField.text!) {
                if matchNum > 99 {
                    alert("There is no way this is match \(matchNum)")
                    textField.text = ""
                } else {
                    KEYS[K_MATCH_NUMBER] = matchNum
                    print("match num is \(textField.text!)")
                }
            } else {
                alert("That is not a number")
                textField.text = ""
            }
        case ViewController.instance.txtPasskey:
            ViewController.instance.peripheralManager.stopAdvertising()
            ViewController.instance.passkey = textField.text
            print("passkey is \(ViewController.instance.passkey)")
            if !isValidID(ViewController.instance.passkey) {
                alert("That is not a valid password- it must be 4 characters long, consiting of either numbers 0-9 or letters A-F")
                return
            }
            UUID_SERVICE = CBUUID(string: ViewController.instance.passkey)
            ViewController.instance.peripheralManager.removeAllServices()
            ViewController.instance.resetPeriphMnger()
            ViewController.instance.peripheralManager.startAdvertising(ViewController.instance.getAdvertisementData())
        default:
            if textField.text == nil {
                return
            }
            KEYS[self.key] = textField.text!
            print("For key: \(self.key), value is: \(textField.text!)")
        }
    }
}