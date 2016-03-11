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

func topMostViewController() -> UIViewController {
    var topCtrller = UIApplication.sharedApplication().keyWindow!.rootViewController
    while topCtrller!.presentedViewController != nil {
        topCtrller = topCtrller!.presentedViewController
    }
    return topCtrller!
}

func alert(message: String) {
    let alert = UIAlertController(title: "Scouting", message: message, preferredStyle: UIAlertControllerStyle.Alert)
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: {
        action -> () in
    }))
    topMostViewController().presentViewController(alert, animated: true, completion: {
        () -> () in
        print("Alerting: \(message)")
    })
}

func alert(message: String, timeout: NSTimeInterval) {
    let alert = UIAlertController(title: "Scouting", message: message, preferredStyle: UIAlertControllerStyle.Alert)
    topMostViewController().presentViewController(alert, animated: true, completion: {
        () -> () in
        print("Alerting: \(message)")
        NSTimer.scheduledTimerWithTimeInterval(timeout, repeats: false, block: {
            alert.dismissViewControllerAnimated(true, completion: nil)
        })
    })
}

func alert(message: String, completion: () -> ()) {
    let alert = UIAlertController(title: "Scouting", message: message, preferredStyle: UIAlertControllerStyle.Alert)
    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: {
        action -> () in
        completion()
    }))
    topMostViewController().presentViewController(alert, animated: true, completion: {
        print("Alerting: \(message)")
    })
}

extension UIView {
    func startRotating(duration: Double) {
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
