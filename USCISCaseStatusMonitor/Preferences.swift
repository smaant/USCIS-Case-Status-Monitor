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
    static let currentStatus = "currentStatus"
    static let lastSyncedAt = "lastSyncedAt"
}

func readCaseStatus(key: String) -> CaseStatus? {
    if let jsonData = UserDefaults.standard.data(forKey: key) {
        return try? JSONDecoder().decode(CaseStatus.self, from: jsonData)
    }
    return nil
}

func writeCaseStatus(value: CaseStatus?, key: String) {
    if value == nil {
        UserDefaults.standard.removeObject(forKey: key)
        return
    }
    if let encoded = try? JSONEncoder().encode(value) {
        UserDefaults.standard.set(encoded, forKey: key)
    } else {
        let message = "Unable to encode CaseStatus: \(value!)"
        os_log("%{public}@", message)
    }
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
            return readCaseStatus(key: PrefKeys.lastAcknowledgedStatus)
        }
        set {
            writeCaseStatus(value: newValue, key: PrefKeys.lastAcknowledgedStatus)
        }
    }
    
    var currentStatus: CaseStatus? {
        get {
            return readCaseStatus(key: PrefKeys.currentStatus)
        }
        set {
            writeCaseStatus(value: newValue, key: PrefKeys.currentStatus)
        }
    }
    
    var lastSyncedAt: String? {
        get {
            return UserDefaults.standard.string(forKey: PrefKeys.lastSyncedAt)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: PrefKeys.lastSyncedAt)
        }
    }
}
