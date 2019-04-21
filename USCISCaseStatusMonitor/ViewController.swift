//
//  ViewController.swift
//  USCIS Case Status Checker
//
//  Created by Anton Panferov on 4/17/19.
//  Copyright © 2019 Anton Panferov. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    var prefs = Preferences()

    override func viewDidLoad() {
        super.viewDidLoad()

        caseNumber.stringValue = prefs.caseNumber ?? ""
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    override func viewWillDisappear() {
        prefs.caseNumber = caseNumber.stringValue
        NotificationCenter.default.post(name: NSNotification.Name("PrefsChanged"), object: nil)
    }
    
    @IBOutlet weak var caseNumber: NSTextField!
}

