//
//  Util.swift
//  Scouting
//
//  Created by Alex DeMeo on 1/8/16.
//  Copyright © 2016 Alex DeMeo. All rights reserved.
//

import UIKit

var KEYS: NSMutableDictionary = NSMutableDictionary()

extension String {
    mutating func remove(str: String) {
        if self.containsString(str) {
            let range = self.rangeOfString(str)
            self.removeRange(range!)
            self = self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        }
    }
    
    mutating func cleanupArgs() -> [String] {
        self.removeAtIndex(self.startIndex)
        self.removeAtIndex(self.endIndex.predecessor())
        return self.componentsSeparatedByString(",")
    }
    
    func trim() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
}

func alert(message: String) {
    let alert = UIAlertController(title: "Scouting", message: message, preferredStyle: UIAlertControllerStyle.Alert)
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: {
        action -> () in
    }))
    ViewController.instance.presentViewController(alert, animated: true, completion: {
        () -> () in
        print("Alerting: \(message)")
    })
}