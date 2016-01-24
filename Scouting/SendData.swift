//
//  SendData.swift
//  Scouting
//
//  Created by Alex DeMeo on 1/8/16.
//  Copyright © 2016 Alex DeMeo. All rights reserved.
//

import CoreBluetooth

let K_TEAM_NUMBER = "team_num"
let K_MATCH_NUMBER = "match_num"
let K_TEAM_COLOR = "team_color"

extension ViewController {
    var advertisementData: [String : AnyObject] {
        get {
            return [
                CBAdvertisementDataServiceUUIDsKey : [UUID_SERVICE],
                CBAdvertisementDataIsConnectable : true,
                CBAdvertisementDataLocalNameKey : "Scouting"
            ]
        }
    }
    
    func sendData() {
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
    
    func startAgain() {
        sendingEOM = false
        self.sendDataIndex = 0
        self.dataToSend = nil
        self.reset()
        self.setDefaults()
    }
    
    func send() {
        var data: NSData?
        do {
            data = try NSJSONSerialization.dataWithJSONObject(KEYS, options: NSJSONWritingOptions.PrettyPrinted)
        } catch _ {
            data = nil
        }
        self.dataToSend = (data!.mutableCopy() as! NSMutableData)
        print("size is \(self.dataToSend!.length)")
        if sendingEOM {
            let didSend = self.peripheralManager.updateValue("EOM".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!, forCharacteristic: self.characteristic, onSubscribedCentrals: nil)
            
            if didSend {
                startAgain()
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
            didSend = self.peripheralManager.updateValue(chunk, forCharacteristic: self.characteristic, onSubscribedCentrals: nil)
            
            if !didSend {
                return
            }
            print("SENT: \(NSString(data: chunk, encoding: NSUTF8StringEncoding))")
            self.sendDataIndex += amountToSend
            if self.sendDataIndex >= self.dataToSend!.length {
                sendingEOM = true
                let eomSent = self.peripheralManager.updateValue("EOM".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!, forCharacteristic: self.characteristic, onSubscribedCentrals: nil)
                if eomSent {
                    startAgain()
                    print("Sent: EOM")
                }
                return
            }
        }
    }
}

