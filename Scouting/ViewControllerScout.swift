//
//  ViewControllerScout.swift
//  Scouting
//
//  Created by Alex DeMeo on 2/18/16.
//  Copyright © 2016 Alex DeMeo. All rights reserved.
//

import UIKit

class ViewControllerScout: UIViewController {
    @IBOutlet var txtTeamNum: UITextField!
    @IBOutlet var txtMatchNum: UITextField!
    @IBOutlet var segTeamColor: UISegmentedControl!
    @IBOutlet var btnDone: UIButton!
    @IBOutlet var scrollView: UIScrollView!
    
    var gestureCloseKeyboard: UITapGestureRecognizer!
    
    internal static var instance: ViewControllerScout!
    
    internal static var arrayStepperViews: [ViewStepper] = [ViewStepper]()
    internal static var arrayTextFieldViews: [ViewTextField] = [ViewTextField]()
    internal static var arraySegCtrlViews: [ViewSegCtrl] = [ViewSegCtrl]()
    internal static var arrayLabelViews: [ViewLabel] = [ViewLabel]()
    internal static var arraySwitchViews: [ViewSwitch] = [ViewSwitch]()
    internal static var arraySliderViews: [ViewSlider] = [ViewSlider]()
    internal static var arraySpaceViews: [CustomView] = [CustomView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.gestureCloseKeyboard = UITapGestureRecognizer(target: self, action: "closeKeyboard:")
        print("Loaded Scout View Controller")
        self.scrollView.addGestureRecognizer(self.gestureCloseKeyboard)
        self.scrollView.contentSize.height = CGFloat(FileUtil.fileContentsTrimmed.count * CustomView.height) + (self.btnDone.frame.height * 3) + self.segTeamColor.frame.origin.y + 5
        CustomView.nextAvailableY = Int(self.segTeamColor.frame.origin.y / 2)
        self.btnDone.frame = CGRect(x: self.btnDone.frame.origin.x, y: self.scrollView.contentSize.height - self.btnDone.frame.height - 5, width: self.btnDone.frame.width, height: self.btnDone.frame.height)
        self.btnDone.addTarget(ViewControllerMain.instance, action: "sendData:", forControlEvents: UIControlEvents.TouchDown)
        self.txtTeamNum.keyboardType = UIKeyboardType.NumberPad
        self.txtMatchNum.keyboardType = UIKeyboardType.NumberPad
        self.txtTeamNum.delegate = ViewTextField(title: "teamnum", key: "", type: "number")
        self.txtMatchNum.delegate = ViewTextField(title: "matchnum", key: "", type: "number")
        self.segTeamColor.addTarget(ViewSegCtrl(title: "teamcolor", key: "", elements: ["Red", "Blue"]), action: "segTeamColorChanged:", forControlEvents: UIControlEvents.ValueChanged)
        self.segTeamColor.selectedSegmentIndex = 0
        
        for var line in FileUtil.fileContentsTrimmed {
            if line.hasPrefix("SEGMENTED_CONTROL") {
                line.remove("SEGMENTED_CONTROL")
                var parts = line.componentsSeparatedByString(";;")
                if parts.count != 3 {
                    self.failedToBuildInterface("Malformed text file in a SEGMENTED_CONTROL")
                    return
                }
                self.addSegmentedControl(parts[1].trim(), key: parts[2].trim(), elements: parts[0].cleanupArgs())
            } else if line.hasPrefix("TEXTFIELD") {
                line.remove("TEXTFIELD")
                var parts = line.componentsSeparatedByString(";;")
                if parts.count != 3 {
                    self.failedToBuildInterface("Malformed text file in a TEXTFIELD")
                    return
                }
                let args = parts[0].cleanupArgs()
                if args.count != 1 {
                    self.failedToBuildInterface("Malformed TEXTFIELD arguments")
                    return
                }
                self.addTextfield(parts[1].trim(), key: parts[2].trim(), type: args[0])
            } else if line.hasPrefix("STEPPER") {
                line.remove("STEPPER")
                var parts = line.componentsSeparatedByString(";;")
                if parts.count != 3 {
                    self.failedToBuildInterface("Malformed text file in STEPPER")
                    return
                }
                let args = parts[0].cleanupArgs()
                if args.count != 2 {
                    self.failedToBuildInterface("Malformed STEPPER arguments")
                    return
                }
                self.addStepper(parts[1].trim(), key: parts[2].trim(), lowerBound: Int(args[0])!, upperBound: Int(args[1])!)
            } else if line.hasPrefix("LABEL") {
                line.remove("LABEL")
                var parts = line.componentsSeparatedByString(";;")
                if parts.count != 2 {
                    self.failedToBuildInterface("Malformed text file in LABEL")
                    return
                }
                let args = parts[0].cleanupArgs()
                if args.count != 2 {
                    self.failedToBuildInterface("Malformed LABEL arguments")
                    return
                }
                self.addLabel(parts[1].trim(), type: args[0], justification: args[1])
            } else if line.hasPrefix("SWITCH") {
                line.remove("SWITCH")
                var parts = line.componentsSeparatedByString(";;")
                if parts.count != 3 {
                    self.failedToBuildInterface("Malformed text file in SWITCH")
                    return
                }
                let argTitles = parts[1].componentsSeparatedByString(",")
                let argKeys = parts[2].componentsSeparatedByString(",")
                if argTitles.count != argKeys.count {
                    self.failedToBuildInterface("Number of keys and titles for SWITCH do not match up")
                    return
                }
                if argTitles.count > 6 || argKeys.count > 6 {
                    self.failedToBuildInterface("Too many switches, cancelling switch view creation")
                    return
                }
                self.addSwitches(keys: argKeys, names: argTitles)
            } else if line.hasPrefix("SLIDER") {
                line.remove("SLIDER")
                var parts = line.componentsSeparatedByString(";;")
                if parts.count != 3 {
                    self.failedToBuildInterface("Malformed text file in SLIDER")
                    return
                }
                let args = parts[0].cleanupArgs()
                if args.count != 2 {
                    self.failedToBuildInterface("Malformed text file in SLIDER arguments")
                    return
                }
                self.addSlider(Int(args[0])!, upperBound: Int(args[1])!, title: parts[1].trim(), key: parts[2].trim())
            } else if line.hasPrefix("SPACE"){
                self.addSpace()
            }
            
            self.scrollView.backgroundColor = CustomView.colorBlueForView
        }
        self.setColor(UIColor.blueColor())
        
    }
    
    func failedToBuildInterface(error: String) {
        print(error)
        ViewControllerMain.instance.btnRefresh.enabled = false
        self.segTeamColor.enabled = false
        self.txtMatchNum.enabled = false
        self.txtTeamNum.enabled = false
        ViewControllerMain.instance.txtPasskey.enabled = false
        for segCtrlView in ViewControllerScout.arraySegCtrlViews {
            segCtrlView.segCtrl.enabled = false
        }
        for stepperView in ViewControllerScout.arrayStepperViews {
            stepperView.stepper.enabled = false
        }
        for switchView in ViewControllerScout.arraySwitchViews {
            for sw in switchView.switches {
                sw.enabled = false
            }
        }
        for textFieldView in ViewControllerScout.arrayTextFieldViews {
            textFieldView.textField.enabled = false
        }
        for sliderView in ViewControllerScout.arraySliderViews {
            sliderView.slider.enabled = false
        }
        NSTimer.scheduledTimerWithTimeInterval(2, repeats: false, block: {
            alert(error)
        })
    }
    
    func addSegmentedControl(title: String, key: String, elements: [String]) {
        print("Adding SEGMENTED CONTROL with title: \"\(title)\", key: \(key), parts: \(elements)")
        ViewSegCtrl(title: title, key: key, elements: elements).add()
    }
    
    func addTextfield(title: String, key: String, type: String) {
        print("Adding TEXTFIELD with title: \"\(title)\", type: \(type)")
        ViewTextField(title: title, key: key, type: type).add()
    }
    
    func addStepper(title: String, key: String, lowerBound: Int, upperBound: Int) {
        print("Adding STEPPER with title: \"\(title)\", key: \(key), bounds: (\(lowerBound),\(upperBound))")
        ViewStepper(title: title, key: key, lowerBound: lowerBound, upperBound: upperBound).add()
    }
    
    func addLabel(title: String, type: String, justification: String) {
        print("Adding LABEL with title: \"\(title)\", type: \(type), justified: \(justification)")
        ViewLabel(title: title, type: type, justification: justification).add()
    }
    
    func addSwitches(keys keys: [String], names: [String]) {
        print("Adding SWITCHES with names: \(names), key: \(keys)")
        ViewSwitch(title: "", keys: keys, switchTitles: names).add()
    }
    
    func addSlider(lowerBound: Int, upperBound: Int, title: String, key: String) {
        print("Adding SLIDER with bounds: (\(lowerBound), \(upperBound)),title: \(title), key: \(key)")
        ViewSlider(lowerBound: lowerBound, upperBound: upperBound, title: title, key: key).add()
    }
    
    func addSpace() {
        let spaceView = CustomView(title: "", key: "")
        ViewControllerScout.arraySpaceViews.append(spaceView)
        spaceView.add()
    }
    
    
    func setColor(color: UIColor) {
        self.segTeamColor.tintColor = color
        for stepperView in ViewControllerScout.arrayStepperViews {
            stepperView.stepper.tintColor = color
        }
        for segCtrlView in ViewControllerScout.arraySegCtrlViews {
            segCtrlView.segCtrl.tintColor = color
        }
        for switchView in ViewControllerScout.arraySwitchViews {
            for sw in switchView.switches {
                sw.tintColor = color
            }
        }
        for sliderView in ViewControllerScout.arraySliderViews {
            sliderView.slider.tintColor = color
        }
    }
    
    func setDefaults() {
        print("Resseting default values")
        for stepperView in ViewControllerScout.arrayStepperViews {
            KEYS[stepperView.key] = "0"
            stepperView.stepper.value = 0
        }
        for segCtrlView in ViewControllerScout.arraySegCtrlViews {
            segCtrlView.segCtrl.selectedSegmentIndex = 0
            KEYS[segCtrlView.key] = segCtrlView.segCtrl.titleForSegmentAtIndex(0) == nil ? "None" : segCtrlView.segCtrl.titleForSegmentAtIndex(0)!
        }
        for textFieldView in ViewControllerScout.arrayTextFieldViews {
            switch textFieldView.type {
            case "decimal":
                KEYS[textFieldView.key] = "0.0"
            case "normal":
                KEYS[textFieldView.key] = ""
            case "number":
                KEYS[textFieldView.key] = "0"
            default: break
            }
            textFieldView.textField.text = ""
        }
        for stepperView in ViewControllerScout.arrayStepperViews {
            stepperView.stepper.value = 0
            stepperView.changed(stepperView.stepper)
        }
        for switchView in ViewControllerScout.arraySwitchViews {
            for (index, sw) in switchView.switches.enumerate() {
                sw.on = false
                KEYS[switchView.keys[index]] = "No"
                
            }
        }
        for sliderView in ViewControllerScout.arraySliderViews {
            sliderView.slider.value = 0
            KEYS[sliderView.key] = 0
        }
        if topMostViewController() == ViewControllerScout.instance {
            self.txtTeamNum.text = ""
            self.txtMatchNum.text = ""
            self.segTeamColor.selectedSegmentIndex = 0
        }
        KEYS[K_TEAM_NUMBER] = "0"
        KEYS[K_TEAM_COLOR] = "Blue"
        KEYS[K_MATCH_NUMBER] = 0
    }
    
    
    func reset() {
        KEYS.removeAllObjects()
        self.setDefaults()
        self.setColor(UIColor.blueColor())
        self.setViewColor(CustomView.colorBlueForView)
        self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    
    func setViewColor(color: UIColor) {
        self.scrollView.backgroundColor = color
        for labelView in ViewControllerScout.arrayLabelViews {
            labelView.backgroundColor = color
        }
        for segCtrlView in ViewControllerScout.arraySegCtrlViews {
            segCtrlView.backgroundColor = color
        }
        for stepperView in ViewControllerScout.arrayStepperViews {
            stepperView.backgroundColor = color
        }
        for textFieldView in ViewControllerScout.arrayTextFieldViews {
            textFieldView.backgroundColor = color
        }
        for switchView in ViewControllerScout.arraySwitchViews {
            switchView.backgroundColor = color
        }
        for sliderView in ViewControllerScout.arraySliderViews {
            sliderView.backgroundColor = color
        }
        for spaceView in ViewControllerScout.arraySpaceViews {
            spaceView.backgroundColor = color
        }
    }
    
    func startAgain() {
        ViewControllerMain.instance.sendingEOM = false
        ViewControllerMain.instance.sendDataIndex = 0
        ViewControllerMain.instance.dataToSend = nil
        self.reset()
        self.setDefaults()
    }
    
    @IBAction func btnStartBackToMainVC(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    func closeKeyboard(sender: UITapGestureRecognizer) {
        self.scrollView.endEditing(true)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
