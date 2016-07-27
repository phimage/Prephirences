//
//  ViewController.swift
//  Example
//
//  Created by phimage on 27/07/16.
//  Copyright © 2016 phimage. All rights reserved.
//

import UIKit
import Prephirences


class ViewController: UITableViewController {

    // Plist
    @IBOutlet weak var stringLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var boolLabel: UILabel!
    // Main bundle
    @IBOutlet weak var applicationNameBundle: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    // UserDefaults
    @IBOutlet weak var stringFromDefaultLabel: UITextField!
    @IBOutlet weak var numberFromDefaultSlider: UISlider!
    @IBOutlet weak var boolFromDefaultsSwitch: UISwitch!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Static value from plist using the composite object
        stringLabel.text = Preferences[.string] as? String
        numberLabel.text = (Preferences[.number] as? NSNumber)?.stringValue
        boolLabel.text = (Preferences[.bool] as? Bool ?? true) ? "yes" : "no"

        // Main bundle
        applicationNameBundle.text = MainBundle[.CFBundleName] as? String
        versionLabel.text = MainBundle[.CFBundleVersion] as? String

        // From UserDefaults
        stringFromDefaultLabel.text = FromDefaults.string ?? "Enter a string"
        numberFromDefaultSlider.value = UserDefaults["DefaultKeyNumber"] as? Float ?? 0
        boolFromDefaultsSwitch.on = UserDefaults["DefaultKeyBool"] as? Bool ?? true
        
        stringFromDefaultLabel.addTarget(self, action: #selector(ViewController.textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Set values to defaults
    // could also use bind api...
 
    @IBAction func textFieldDidChange(sender: UITextField) {
        FromDefaults.string = sender.text
        UserDefaults.synchronize()
    }
    @IBAction func sliderChanged(sender: UISlider) {
        UserDefaults["DefaultKeyNumber"] = sender.value
        UserDefaults.synchronize()
    }
    @IBAction func switchChanged(sender: UISwitch) {
        UserDefaults["DefaultKeyBool"] = sender.on
        UserDefaults.synchronize()
    }
}

