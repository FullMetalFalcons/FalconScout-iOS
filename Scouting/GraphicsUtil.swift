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
    let alert = UIAlertController(title: "Mistakes were made", message: message, preferredStyle: UIAlertControllerStyle.Alert)
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: {
        action -> () in
    }))
    ViewController.instance.presentViewController(alert, animated: true, completion: {
        () -> () in
        print("Alerting: \(message)")
    })
}

func alert(message: String, timeout: NSTimeInterval) {
    let alert = UIAlertController(title: "Mistakes were made", message: message, preferredStyle: UIAlertControllerStyle.Alert)
    ViewController.instance.presentViewController(alert, animated: true, completion: {
        () -> () in
        print("Alerting: \(message)")
        NSTimer.scheduledTimerWithTimeInterval(timeout, repeats: false, block: {
            alert.dismissViewControllerAnimated(true, completion: nil)
        })
    })
}

extension UIView {
    func startRotating(duration: Double = 1) {
        let kAnimationKey = "rotation"
        if self.layer.animationForKey(kAnimationKey) == nil {
            let animate = CABasicAnimation(keyPath: "transform.rotation")
            animate.duration = duration
            animate.repeatCount = Float.infinity
            animate.fromValue = 0.0
            animate.toValue = -Float(M_PI * 2.0)
            self.layer.addAnimation(animate, forKey: kAnimationKey)
        }
    }
    func stopRotating() {
        let kAnimationKey = "rotation"
        
        if self.layer.animationForKey(kAnimationKey) != nil {
            self.layer.removeAnimationForKey(kAnimationKey)
        }
    }
}