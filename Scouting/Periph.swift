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
 Bluetooth peripheral class. See apple documentation for method info
 */

extension ViewController: CBPeripheralManagerDelegate {
    
    
    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager, error: NSError?) {
        print("Started advertising")
    }
    
    func resetPeriphMnger() {
        self.characteristic = CBMutableCharacteristic(type: UUID_CHARACTERISTIC, properties: CBCharacteristicProperties.Notify, value: self.dataToSend, permissions: CBAttributePermissions.Readable)
        self.characteristic.properties = CBCharacteristicProperties.Notify
        self.theService = CBMutableService(type: UUID_SERVICE, primary: true)
        self.theService.characteristics = [characteristic]
        self.peripheralManager.addService(theService)
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        if peripheral.state == CBPeripheralManagerState.PoweredOn {
            print("Manager powered on")
            self.resetPeriphMnger()
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
        self.sendDataIndex = 0
        self.connectedAndSubscribed = true
        self.lblConnectionStatus.text = "Connection status: Connected"
        self.lblConnectionStatus.textColor = UIColor.greenColor()
        self.peripheralManager.stopAdvertising()
        self.setDefaults()
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFromCharacteristic characteristic: CBCharacteristic) {
        print("Central unsubscribed from characteristic")
        self.connectedAndSubscribed = false
        self.lblConnectionStatus.text = "Connection status: None"
        self.lblConnectionStatus.textColor = UIColor.redColor()
        print("will start advertising with PASSKEY: \(self.passkey)")
        self.peripheralManager.startAdvertising(self.advertisementData)
        
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, didReceiveReadRequest request: CBATTRequest) {
        print("received read request \(request)")
        peripheral.respondToRequest(request, withResult: CBATTError.Success)
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, didReceiveWriteRequests requests: [CBATTRequest]) {
        print("received write request \(requests)")
    }
    
    
    func peripheralManagerIsReadyToUpdateSubscribers(peripheral: CBPeripheralManager) {
        print("ready to update subscribers")
        self.send()
    }
}
