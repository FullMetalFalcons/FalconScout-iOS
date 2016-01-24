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
    internal static var colorAlpha: Float = 0.1
    internal static var nextAvailableY: Int = 0

    var title: String
    var key: String
    
    init(title: String, key: String) {
        self.title = title
        self.key = key
        super.init(frame: CGRect(x: Int(ViewController.instance.view.frame.minX), y: CustomView.nextAvailableY, width: Int(ViewController.instance.view.frame.width), height: CustomView.height))
        CustomView.nextAvailableY += CustomView.height
        self.backgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 1, alpha: CustomView.colorAlpha)
    }

    func add() {
        ViewController.instance.scrollView.addSubview(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
