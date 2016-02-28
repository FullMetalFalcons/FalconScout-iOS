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
    internal static var nextAvailableY: Int = 0
    internal static var colorRedForView = UIColor(red: 1, green: 0, blue: 0, alpha: 0.1)
    internal static var colorBlueForView = UIColor(red: 0, green: 0, blue: 1, alpha: 0.1)
    var title: String
    var key: String
    
    init(title: String, key: String) {
        self.title = title
        self.key = key
        super.init(frame: CGRect(x: Int(ViewControllerMain.instance.view.frame.minX), y: CustomView.nextAvailableY, width: Int(ViewControllerMain.instance.view.frame.width), height: CustomView.height))
        CustomView.nextAvailableY += CustomView.height
        self.backgroundColor = CustomView.colorBlueForView
    
    }

    func add() {
        ViewControllerScout.instance.scrollView.addSubview(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
