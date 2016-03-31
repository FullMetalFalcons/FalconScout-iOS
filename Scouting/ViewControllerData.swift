//
//  ViewControllerSummary.swift
//  Scouting
//
//  Created by Alex DeMeo on 2/18/16.
//  Copyright © 2016 Alex DeMeo. All rights reserved.
//

import UIKit

class ViewControllerData: UIViewController, UITableViewDelegate, UITableViewDataSource {
    internal static var instance: ViewControllerData!
    
    var sendData: NSData!
    var teamDictionary: NSDictionary!
    var teamArrUnsorted = [(key: AnyObject, value: AnyObject)]()
    var teamArrKeysTemp = [AnyObject]()
    var teamArrSorted = [(key: AnyObject, value: AnyObject)]()
    var teamNum: String!
    var gestureCloseKeyboard: UITapGestureRecognizer!
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if teamDictionary == nil {
            print("No Team dictionary")
            return
        }
        self.gestureCloseKeyboard = UITapGestureRecognizer(target: self, action: #selector(ViewControllerData.closeKeyboard(_:)))
        self.view.addGestureRecognizer(self.gestureCloseKeyboard)
        
        for (_, val) in self.teamDictionary.enumerate() {
            teamArrUnsorted.append(val)
            teamArrKeysTemp.append(val.key)
        }
        
        teamArrKeysTemp = teamArrKeysTemp.sort({
            one, two -> Bool in
            let s0 = "\(one)"
            let s1 = "\(two)"
            return s0 < s1
        })
        
        for (index, key) in self.teamArrKeysTemp.enumerate() {
            var key = "\(key)"
            key.replaceRange(key.startIndex...key.startIndex, with: "\(key.characters.first!)".uppercaseString)
            let parts = key.componentsSeparatedByString("_")
            key = ""
            for part in parts {
                key += " \(part)"
            }
            teamArrSorted.append((key, self.teamArrUnsorted[index].value))
            print("\(key)=\(self.teamArrUnsorted[index].value)")
        }
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FileUtil.fileContentsTrimmed.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
        var cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "")
        let index = indexPath.row
        let col = self.teamArrSorted[index].key
        let colStr = "\(col)"
        var colRawStr = "\(self.teamArrKeysTemp[index])"
        
        var raw: String!
        var percent: String!
        if colStr.hasSuffix("yes") || colStr.hasSuffix("no") {
            self.trimYesOrNo(&colRawStr)
            let keyTrimY = "\(colRawStr)_yes"
            let keyTrimN = "\(colRawStr)_no"
            let doubleY = Double("\(self.teamDictionary[keyTrimY]!)")!
            let doubleN = Double("\(self.teamDictionary[keyTrimN]!)")!
            raw =  "\(doubleY / (doubleY + doubleN))"
            percent =  "\(doubleY / (doubleY + doubleN) * 100)"
        } else {
            raw = "\(self.teamArrSorted[index].value)"
            if raw.hasSuffix("}") {
                raw.remove("}")
                raw.remove("{")
            }
            if let d = Double(raw) {
                percent = "\(d * 100)"
            } else {
                percent = ""
            }
        }

        self.build(&cell, col: "\(colStr)", raw: raw, percent: percent)
        return cell
    }
    func trimYesOrNo(inout str: String) {
        if str.hasSuffix("_no") {
            str.remove("_no")
        } else if str.hasSuffix("_yes") {
            str.remove("_yes")
        }
    }
    
    @IBAction func btnGoBack(sender: UIButton) {
        print("GO BACK")
        self.dismissViewControllerAnimated(true, completion: {
            ViewControllerRequest.instance.dismissViewControllerAnimated(true, completion: {})
        })
    }
    
    private func toIntFromDict(key: String) -> Int {
        return Int("\(teamDictionary[key]!)")!
    }
    
    private func toStringFromDict(key: String) -> String {
        return "\(teamDictionary[key]!)"
    }
    
    func closeKeyboard(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    class func reinstantiate(dict: NSMutableDictionary) {
        ViewControllerData.instance = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Data") as! ViewControllerData
        ViewControllerData.instance.teamDictionary = dict
    }
    
    func build(inout cell: UITableViewCell, col: String, raw: String, percent: String) {
        var lbls = [UILabel]()
        let tableWidth = self.tableView.frame.width
        lbls.append(UILabel(frame: CGRect(x: 0, y: 0, width: tableWidth / 1.5, height: cell.frame.height)))
        lbls.append(UILabel(frame: CGRect(x: tableWidth / 3, y: 0, width: tableWidth / 3, height: cell.frame.height)))
        lbls.append(UILabel(frame: CGRect(x: tableWidth * (2/3), y: 0, width: tableWidth / 3, height: cell.frame.height)))
        lbls[0].text = col
        lbls[0].textAlignment = NSTextAlignment.Left
        lbls[0].font = UIFont.systemFontOfSize(10)
        lbls[1].text = raw
        lbls[1].textAlignment = NSTextAlignment.Center
        lbls[2].text = percent
        lbls[2].textAlignment = NSTextAlignment.Right
        
        for lbl in lbls {
            lbl.font = UIFont.systemFontOfSize(12)
            cell.addSubview(lbl)
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}

