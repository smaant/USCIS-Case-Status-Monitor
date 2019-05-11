//
//  TabViewController.swift
//  USCISCaseStatusMonitor
//
//  Created by Anton Panferov on 5/5/19.
//  Copyright © 2019 Anton Panferov. All rights reserved.
//

import Cocoa

class TabViewController: NSTabViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    class func loadFromNib() -> TabViewController {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateController(withIdentifier: "TabViewController") as! TabViewController
    }
}
