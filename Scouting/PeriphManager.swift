//
//  Periph.swift
//  Scouting
//
//  Created by Alex DeMeo on 1/8/16.
//  Copyright © 2016 Alex DeMeo. All rights reserved.
//

import CoreBluetooth
import UIKit

/**
Bluetooth peripheral manager class. See apple documentation for method info
*/
private var dataStr = ""
extension ViewControllerMain: CBPeripheralManagerDelegate {
    
    
    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager, error: NSError?) {
        print("Started advertising")
    }
    
    func resetPeriphManager() {
        self.theService = CBMutableService(type: UUID_SERVICE, primary: true)
        self.theService.characteristics = [CHARACTERISTIC_ROBOT, CHARACTERISTIC_DB]
        self.peripheralManager.addService(theService)
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        if peripheral.state == CBPeripheralManagerState.PoweredOn {
            print("Manager powered on")
            self.resetPeriphManager()
        }
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, didAddService service: CBService, error: NSError?) {
        if error != nil {
            print("error: \(error)")
        } else {
            self.peripheralManager.startAdvertising(self.advertisementData)
            print("advertising UUID(passkey)")
        }
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, central: CBCentral, didSubscribeToCharacteristic characteristic: CBCharacteristic) {
        print("Central subscribed to characteristic. Max bytes allowed = \(central.maximumUpdateValueLength)")
        self.btnRefresh.enabled = false
        self.sendDataIndex = 0
        self.connectedAndSubscribed = true
        self.lblConnectionStatus.text = "Connected!"
        self.lblConnectionStatus.textColor = UIColor.greenColor()
        self.peripheralManager.stopAdvertising()
        ViewControllerScout.instance.setDefaults()
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFromCharacteristic characteristic: CBCharacteristic) {
        print("Central unsubscribed from characteristic")
        self.connectedAndSubscribed = false
        self.lblConnectionStatus.text = "No connection"
        self.btnRefresh.enabled = true
        self.lblConnectionStatus.textColor = UIColor.redColor()
        print("will start advertising with PASSKEY: \(self.passkey)")
        self.peripheralManager.startAdvertising(self.advertisementData)
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, didReceiveReadRequest request: CBATTRequest) {
        print("received read request \(request)")
        peripheral.respondToRequest(request, withResult: CBATTError.Success)
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, didReceiveWriteRequests requests: [CBATTRequest]) {
        for request in requests {
            peripheral.respondToRequest(request, withResult: CBATTError.Success)
            let rStr = NSString(data: request.value!, encoding: NSUTF8StringEncoding)!
            switch rStr {
            case "EOM":
                ViewControllerRequest.instance.showSummaryWithStringData(dataStr)
                dataStr = ""
            case "NoReadTable":
                ViewControllerRequest.instance.loadingSpinner.stopAnimating()
                alert("The computer was unable to read the table")
            case "NoReadTeam":
                ViewControllerRequest.instance.loadingSpinner.stopAnimating()
                alert("That team could not be found on the computer's database")
            default:
                dataStr += rStr
            }
        }
    }
    
    func peripheralManagerIsReadyToUpdateSubscribers(peripheral: CBPeripheralManager) {
        self.send()
    }
}
