//
//  CustomView.swift
//  InterfaceConstruction
//
//  Created by Alex DeMeo on 1/6/16.
//  Copyright © 2016 Alex DeMeo. All rights reserved.
//

import UIKit

class CustomView: UIView {
    internal static var height = 50;
    internal static let textSize: CGFloat = 16

    var title: String
    var key: String
    
    init(title: String, key: String) {
        self.title = title
        self.key = key
        super.init(frame: CGRect(x: Int(ViewController.instance.view.frame.minX), y: ViewController.nextAvailableY, width: Int(ViewController.instance.view.frame.width), height: CustomView.height))
        ViewController.nextAvailableY += CustomView.height
        ViewController.instance.setViewColor(UIColor(colorLiteralRed: 0, green: 0, blue: 1, alpha: 0.25))
    }

    func add() {
        ViewController.instance.scrollView.addSubview(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
