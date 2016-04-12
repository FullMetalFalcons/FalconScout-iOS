//
//  ViewController.swift
//  Scouting
//
//  Created by Alex DeMeo on 1/7/16.
//  Copyright © 2016 Alex DeMeo. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewControllerMain: UIViewController {
    
    var sendingEOM = false
    var sendDataIndex = 0
    var passkey: String! = ""
    var dataToSend: NSMutableData?
    var connectedAndSubscribed: Bool = false
    
    var peripheralManager: CBPeripheralManager!
    var theService: CBMutableService!
    
    @IBOutlet var lblConnectionStatus: UILabel!
    @IBOutlet var txtPasskey: UITextField!
    
    @IBOutlet var btnRefresh: UIButton!
    @IBOutlet var btnScout: UIButton!
    @IBOutlet var btnRetrieveData: UIButton!
    
    var gestureCloseKeyboard: UITapGestureRecognizer!
    
    internal static var instance: ViewControllerMain!
    
    var advertisementData: [String : AnyObject] {
        get {
            return [
                CBAdvertisementDataServiceUUIDsKey : [UUID_SERVICE],
                CBAdvertisementDataIsConnectable : true,
                CBAdvertisementDataLocalNameKey : "Scouting-\(UIDevice.currentDevice().name)"
            ]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Loaded Main View Controller")
        if isFirstLaunch {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            ViewControllerMain.instance = self
            ViewControllerInfo.instance = storyboard.instantiateViewControllerWithIdentifier("Info") as! ViewControllerInfo
            ViewControllerScout.instance = storyboard.instantiateViewControllerWithIdentifier("Scout") as! ViewControllerScout
            ViewControllerData.instance = storyboard.instantiateViewControllerWithIdentifier("Data") as! ViewControllerData
            ViewControllerRequest.instance = storyboard.instantiateViewControllerWithIdentifier("Request") as! ViewControllerRequest
            ViewControllerScout.instance.initialize()
            isFirstLaunch = false
        }
        self.gestureCloseKeyboard = UITapGestureRecognizer(target: self, action: #selector(ViewControllerMain.closeKeyboard(_:)))
        self.view.addGestureRecognizer(self.gestureCloseKeyboard)
        
        self.txtPasskey.keyboardType = UIKeyboardType.NamePhonePad
        self.txtPasskey.delegate = self//ViewTextField(title: "passkey", key: "", type: "normal")

        self.btnScout.addTarget(self, action: #selector(ViewControllerMain.btnStartScouting(_:event:)), forControlEvents: UIControlEvents.TouchDown)
        self.btnRetrieveData.addTarget(self, action: #selector(ViewControllerMain.btnStartRetrievingData(_:event:)), forControlEvents: UIControlEvents.TouchDown)
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
    }
    
    func btnStartScouting(sender: UIButton, event: UIEvent) {
        let location = event.touchesForView(sender)!.first!.locationInView(sender)
        let touchColor = self.colorOfPoint(sender, point: location)
        if CGColorEqualToColor(touchColor, UIColor(red: 0, green: 0, blue: 0, alpha: 0).CGColor) {
            return
        }
        sender.setBackgroundImage(UIImage(named: "Red-Left-Down"), forState: UIControlState.Normal)
        NSTimer.scheduledTimerWithTimeInterval(0.1, repeats: false, block: {
            sender.setBackgroundImage(UIImage(named: "Red-Left-Up"), forState: UIControlState.Normal)
        })
        if self.connectedAndSubscribed {
            self.presentViewController(ViewControllerScout.instance, animated: true, completion: {
                ViewControllerScout.instance.setDefaults()
            })
        } else {
            alert("Please connect to a central computer to Scout")
        }
    }
    
    func btnStartRetrievingData(sender: UIButton, event: UIEvent) {
        let location = event.touchesForView(sender)!.first!.locationInView(sender)
        let touchColor = self.colorOfPoint(sender, point: location)
        if CGColorEqualToColor(touchColor, UIColor(red: 0, green: 0, blue: 0, alpha: 0).CGColor) {
            return
        }
        sender.setBackgroundImage(UIImage(named: "Blue-Right-Down"), forState: UIControlState.Normal)
        NSTimer.scheduledTimerWithTimeInterval(0.1, repeats: false, block: {
            sender.setBackgroundImage(UIImage(named: "Blue-Right-Up"), forState: UIControlState.Normal)
        })
        if self.connectedAndSubscribed {
            self.presentViewController(ViewControllerRequest.instance, animated: true, completion: {})
        } else {
            alert("Please connect to a central to get team data from it")
        }
    }
    
    private func colorOfPoint(view: UIView, point:CGPoint) -> CGColor {
        var pixel:[CUnsignedChar] = [0,0,0,0]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue)
        let context = CGBitmapContextCreate(&pixel, 1, 1, 8, 4, colorSpace, bitmapInfo.rawValue)
        CGContextTranslateCTM(context, -point.x, -point.y)
        view.layer.renderInContext(context!)
        let red:CGFloat = CGFloat(pixel[0])/255.0
        let green:CGFloat = CGFloat(pixel[1])/255.0
        let blue:CGFloat = CGFloat(pixel[2])/255.0
        let alpha:CGFloat = CGFloat(pixel[3])/255.0
        let color = UIColor(red:red, green: green, blue:blue, alpha:alpha)
        return color.CGColor
    }

    @IBAction func btnRefresh(sender: UIButton) {
        self.refresh(self.passkey)
    }
    
    func refresh(passkey: String) {
        print("Refresh")
        self.btnRefresh.startRotating(1)
        self.btnRefresh.enabled = false
        NSTimer.scheduledTimerWithTimeInterval(2, repeats: false, block: {
            _ in
            self.btnRefresh.enabled = true
            self.btnRefresh.stopRotating()
        })
        
        self.peripheralManager.stopAdvertising()
        self.passkey = passkey
        print("passkey is \(self.passkey)")
        if !isValidID(self.passkey) {
            alert("That is not a valid password- it must be 4 characters long, consiting of either numbers 0-9 or letters A-F")
            return
        }
        UUID_SERVICE = CBUUID(string: "\(self.passkey)5888-16f1-43f8-aa84-63f1544f2694")
        self.peripheralManager.removeAllServices()
        self.resetPeriphManager()
        self.peripheralManager.startAdvertising(self.advertisementData)
    }
    
    
    func sendData(sender: UIButton) {
        if ViewControllerMain.instance.connectedAndSubscribed {
            if dataToSend == nil {
                if KEYS[K_TEAM_NUMBER] == nil {
                    alert("Please input the team number again")
                    return
                }
                send()
            } else {
                dataToSend = nil
            }
        } else {
            alert("You're not connected to a central computer")
        }
        
    }
    
    @IBAction func infoButtonPressed(sender: UIButton) {
        self.presentViewController(ViewControllerInfo.instance, animated: true, completion: {})
    }
    
    
    func closeKeyboard(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @objc func sendData() {
        if self.connectedAndSubscribed {
            if dataToSend == nil {
                if KEYS[K_TEAM_NUMBER] as! Int == 0 {
                    alert("Please input the team number again")
                    return
                }
                send()
            } else {
                dataToSend = nil
            }
        } else {
            alert("You're not connected to a central computer")
        }
    }
    
    func send() {
        var finData: NSData?
        do {
            finData = try NSPropertyListSerialization.dataWithPropertyList(KEYS, format: .XMLFormat_v1_0, options: 0)
        } catch {}
        let someStrThing = NSString(data: finData!, encoding: NSUTF8StringEncoding)
        let data = someStrThing!.dataUsingEncoding(NSUTF8StringEncoding)
        self.dataToSend = (data!.mutableCopy() as! NSMutableData)
        if sendingEOM {
                let didSend = self.peripheralManager.updateValue("EOM".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!, forCharacteristic: CHARACTERISTIC_ROBOT, onSubscribedCentrals: nil)
            if didSend {
                ViewControllerScout.instance.startAgain()
                print("SENT: EOM")
            }
            return
        }
        if self.sendDataIndex >= self.dataToSend!.length {
            return
        }
        var didSend = true
        while didSend {
            var amountToSend = self.dataToSend!.length - self.sendDataIndex
            if amountToSend > NOTIFY_MTU {
                amountToSend = NOTIFY_MTU
            }
            let chunk = NSData(bytes: self.dataToSend!.bytes + self.sendDataIndex, length: amountToSend)
            didSend = self.peripheralManager.updateValue(chunk, forCharacteristic: CHARACTERISTIC_ROBOT, onSubscribedCentrals: nil)
            if !didSend {
                print("Failed to send chunk of data from \(self.sendDataIndex) to \(self.sendDataIndex + amountToSend)")
                return
            }
            print("Sent from \(self.sendDataIndex) to \(self.sendDataIndex + amountToSend)")
            self.sendDataIndex += amountToSend
            if self.sendDataIndex >= self.dataToSend!.length {
                sendingEOM = true
                let eomSent = self.peripheralManager.updateValue("EOM".dataUsingEncoding(NSUTF8StringEncoding)!, forCharacteristic: CHARACTERISTIC_ROBOT, onSubscribedCentrals: nil)
                if eomSent {
                    ViewControllerScout.instance.startAgain()
                    print("Sent: EOM")
                }
                return
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}

extension ViewControllerMain: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.superview!.endEditing(true)
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        return true
    }

    
    func textFieldDidEndEditing(textField: UITextField) {
        switch textField {
        case self.txtPasskey:
            self.refresh(textField.text!)
        default: break
        }
    }
}
