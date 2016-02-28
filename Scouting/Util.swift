//
//  Operator.swift
//  Scouting
//
//  Created by Alex DeMeo on 2/24/16.
//  Copyright © 2016 Alex DeMeo. All rights reserved.
//

import Foundation

infix operator += {}

func +=(inout start: String!, append: String) {
    start.appendContentsOf("\(append)\n")
}

func +=(inout start: NSString, append: NSString) {
    start = "\(start)\(append)"
}

func +=(inout start: String, append: NSString) {
    start.appendContentsOf("\(append)")
}

func +=(inout start: NSString, append: String) {
    start = "\(start)\(append)"
}

extension NSData {
    func toDataArray(MTU: Int) -> [NSData] {
        var index = 0
        var arr = [NSData]()
        let lastBit = self.length % MTU
        let nIterations = (self.length - lastBit) / MTU
        for i in 0...nIterations {
            let chunk = NSData(bytes: self.bytes + index, length: i == nIterations ? lastBit : MTU)
            arr.append(chunk)
            index += MTU
            
        }
        return arr
    }
}