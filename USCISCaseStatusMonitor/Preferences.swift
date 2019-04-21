//
//  Preferences.swift
//  USCISCaseStatusMonitor
//
//  Created by Anton Panferov on 4/20/19.
//  Copyright © 2019 Anton Panferov. All rights reserved.
//

import Foundation

struct Preferences {
    var caseNumber: String? {
        get {
            let savedNumber = UserDefaults.standard.string(forKey: "caseNumber")
            return savedNumber
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "caseNumber")
        }
    }
}
