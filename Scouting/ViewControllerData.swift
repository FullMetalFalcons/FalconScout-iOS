//
//  ViewControllerSummary.swift
//  Scouting
//
//  Created by Alex DeMeo on 2/18/16.
//  Copyright © 2016 Alex DeMeo. All rights reserved.
//

import UIKit

class ViewControllerData: UIViewController {
    internal static var instance: ViewControllerData!
    
    var sendData: NSData!
    var teamDictionary: NSDictionary!
    var teamNum: String!
    var gestureCloseKeyboard: UITapGestureRecognizer!
    
    @IBOutlet var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        if teamDictionary == nil {
            print("No Team dictionary")
            return
        }
        self.gestureCloseKeyboard = UITapGestureRecognizer(target: self, action: "closeKeyboard:")
        self.view.addGestureRecognizer(self.gestureCloseKeyboard)

        self.textView.text += "Here is a summary for team \(teamDictionary["team_num"]!):\n\n"
        self.textView.text += "AUTONOMOUS"
        self.textView.text += self.total("Times crossed portcullis", self.toIntFromDict("aut_portcullis_yes"), self.toIntFromDict("aut_portcullis_no"))
        self.textView.text += self.total("Times crossed Cheval Frise", self.toIntFromDict("aut_chevaldefrise_yes"), self.toIntFromDict("aut_chevaldefrise_no"))
        self.textView.text += self.total("Times crossed Moat", self.toIntFromDict("aut_moat_yes"), self.toIntFromDict("aut_moat_no"))
        self.textView.text += self.total("Times crossed Ramparts", self.toIntFromDict("aut_ramparts_yes"), self.toIntFromDict("aut_ramparts_no"))
        self.textView.text += self.total("Times crossed Drawbridge", self.toIntFromDict("aut_drawbridge_yes"), self.toIntFromDict("aut_drawbridge_no"))
        self.textView.text += self.total("Times crossed Sally Port", self.toIntFromDict("aut_sallyport_yes"), self.toIntFromDict("aut_sallyport_no"))
        self.textView.text += self.total("Times crossed Rock wall", self.toIntFromDict("aut_rockwall_yes"), self.toIntFromDict("aut_rockwall_no"))
        self.textView.text += self.total("Times crossed Rough Terrain", self.toIntFromDict("aut_rough_terrain_yes"), self.toIntFromDict("aut_rough_terrain_no"))
        self.textView.text += "\nTELEOP"
        self.textView.text += self.total("Times crossed portcullis", self.toIntFromDict("teleop_portcullis_yes"), self.toIntFromDict("teleop_portcullis_no"))
        self.textView.text += self.total("Times crossed Cheval Frise", self.toIntFromDict("teleop_chevaldefrise_yes"), self.toIntFromDict("teleop_chevaldefrise_no"))
        self.textView.text += self.total("Times crossed Moat", self.toIntFromDict("teleop_moat_yes"), self.toIntFromDict("teleop_moat_no"))
        self.textView.text += self.total("Times crossed Ramparts", self.toIntFromDict("teleop_ramparts_yes"), self.toIntFromDict("teleop_ramparts_no"))
        self.textView.text += self.total("Times crossed Drawbridge", self.toIntFromDict("teleop_drawbridge_yes"), self.toIntFromDict("teleop_drawbridge_no"))
        self.textView.text += self.total("Times crossed Sally Port", self.toIntFromDict("teleop_sallyport_yes"), self.toIntFromDict("teleop_sallyport_no"))
        self.textView.text += self.total("Times crossed Rock wall", self.toIntFromDict("teleop_rockwall_yes"), self.toIntFromDict("teleop_rockwall_no"))
        self.textView.text += self.total("Times crossed Rough Terrain", self.toIntFromDict("teleop_rough_terrain_yes"), self.toIntFromDict("teleop_rough_terrain_no"))
        
        self.textView.text += self.total("High goals per total matches", self.toIntFromDict("teleop_shots_highgoal"), self.toIntFromDict("num_matches"))
        self.textView.text += self.total("Low goals per total matches", self.toIntFromDict("teleop_shots_lowgoal"), self.toIntFromDict("num_matches"))
        self.textView.text += self.total("Times climbed per total matches", self.toIntFromDict("teleop_climbing_yes"), self.toIntFromDict("num_matches"))
        self.textView.text += "Average shot accuracy = \(teamDictionary["teleop_shot_accuracy"]!)"
        self.textView.text += "Total points scored in competition: \(self.toStringFromDict("teleop_total_points"))"
        
        
    }
    
    @IBAction func btnGoBack(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: {
            ViewControllerRequest.instance.dismissViewControllerAnimated(true, completion: {})
        })
    }
    
    private func total(name: String, _ i1: Int, _ i2: Int) -> String {
        return "\(name): \(i1)/\(i1 + i2) = \((Double(i1) / Double(i1 + i2)) * 100)%"
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
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
