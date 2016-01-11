//
//  BluetoothUtil.swift
//  Scouting
//
//  Created by Alex DeMeo on 1/8/16.
//  Copyright © 2016 Alex DeMeo. All rights reserved.
//

import CoreBluetooth
import UIKit


public var UUID_SERVICE: CBUUID = CBUUID(string: "333B")
public let UUID_CHARACTERISTIC: CBUUID = CBUUID(string: "200B")

public let NOTIFY_MTU: NSInteger = 75

func isValidID(id: String) -> Bool {
    let lwr = id.lowercaseString
    func isInt(char: Character) -> Bool {
        for i in 0...9 {
            if String(char) == "\(i)" {
                return true
            }
        }
        return false
    }
    
    if lwr.characters.count != 4 {
        return false
    } else {
        for char: Character in lwr.characters {
            if !isInt(char) {
                if  char != "a" &&
                    char != "b" &&
                    char != "c" &&
                    char != "d" &&
                    char != "e" &&
                    char != "f" {
                        return false
                }
            }
        }
    }
    return true;
}
