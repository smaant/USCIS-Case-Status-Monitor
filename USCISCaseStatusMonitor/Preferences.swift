//
//  Preferences.swift
//  USCISCaseStatusMonitor
//
//  Created by Anton Panferov on 4/20/19.
//  Copyright © 2019 Anton Panferov. All rights reserved.
//

import Foundation
import os.log

enum PrefKeys {
    static let caseNumber = "caseNumber"
    static let lastAcknowledgedStatus = "lastAcknowledgedStatus"
}

struct Preferences {
    var caseNumber: String? {
        get {
            return UserDefaults.standard.string(forKey: PrefKeys.caseNumber)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: PrefKeys.caseNumber)
        }
    }
        
    var lastAcknowledgedStatus: CaseStatus? {
        get {
            if let jsonData = UserDefaults.standard.data(forKey: PrefKeys.lastAcknowledgedStatus) {
                return try? JSONDecoder().decode(CaseStatus.self, from: jsonData)
            }
            return nil
        }
        set {
            if newValue == nil {
                UserDefaults.standard.removeObject(forKey: PrefKeys.lastAcknowledgedStatus)
                return
            }
            if let encoded = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(encoded, forKey: PrefKeys.lastAcknowledgedStatus)
            } else {
                let message = "Unable to encode CaseStatus: \(newValue!)"
                os_log("%{public}@", message)
            }
        }
    }
}
