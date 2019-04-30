//
//  AppDelegate.swift
//  USCIS Case Status Checker
//
//  Created by Anton Panferov on 4/17/19.
//  Copyright © 2019 Anton Panferov. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let menu = NSMenu()
    
    var statusMenuItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
    var descriptionMenuItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
    var lastUpdateMenuItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
    var ackMenuItem = NSMenuItem(title: "Aknowledge current status", action: #selector(acknowledgeCurrentStatus(sender:)), keyEquivalent: "")
    
    let dateFormater = DateFormatter()
    
    let updateInterval = 600.0
    var prefs = Preferences()
    var currentStatus: CaseStatus?
    
    let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
    var preferencesController: NSWindowController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        dateFormater.dateFormat = "dd/mm/YYYY, h:mm:ss a"
        
        if let button = statusItem.button {
            button.image = NSImage(named: "unchanged")
        }
        
        menu.addItem(statusMenuItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(descriptionMenuItem)
        menu.addItem(lastUpdateMenuItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(ackMenuItem)
        menu.addItem(NSMenuItem(title: "Preferences...", action: #selector(showPrefeneces(sender:)), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusMenuItem.isEnabled = false
        descriptionMenuItem.isEnabled = false
        lastUpdateMenuItem.isEnabled = false
        menu.autoenablesItems = false
        
        statusItem.menu = menu
        
        updateStatus()
        Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { (timer) in
            self.updateStatus()
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("PrefsChanged"), object: nil, queue: nil) { (notification) in
            self.prefs.lastAcknowledgedStatus = nil
            self.updateStatus()
        }
        
        preferencesController = storyboard.instantiateController(withIdentifier: "PreferencesWindowController") as? NSWindowController
    }
    
    @objc func acknowledgeCurrentStatus(sender: NSMenuItem) {
        if let currentStatus = currentStatus {
            prefs.lastAcknowledgedStatus = currentStatus
            updateMenuBarIcon(newStatus: currentStatus)
        }
    }
    
    func updateMenuBarIcon(newStatus: CaseStatus?) {
        if prefs.lastAcknowledgedStatus == nil {
            prefs.lastAcknowledgedStatus = newStatus
        }
        
        if prefs.lastAcknowledgedStatus == newStatus {
            statusItem.button?.image = NSImage(named: "unchanged")
            ackMenuItem.isEnabled = false
        } else {
            statusItem.button?.image = NSImage(named: "changed")
            ackMenuItem.isEnabled = true
        }
    }
    
    func updateStatus() {
        switch USCISStatus().fetchCurrentStatus(caseNumber: prefs.caseNumber ?? "") {
        case .value(let currentStatus):
            self.currentStatus = currentStatus
            updateMenuBarIcon(newStatus: currentStatus)
            
            let description = splitStringToLines(
                currentStatus.description.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression),
                50)
            
            statusMenuItem.title = currentStatus.status
            descriptionMenuItem.attributedTitle = NSAttributedString(string: description, attributes: nil)
            descriptionMenuItem.isHidden = false
            
        case .error(_):
            self.currentStatus = nil
            updateMenuBarIcon(newStatus: nil)
            statusMenuItem.title = "Error: Unable to get case status. Check case number."
            descriptionMenuItem.isHidden = true
        }
        
        lastUpdateMenuItem.title = "Updated at: " + dateFormater.string(from: Date())
    }
    
    @objc func showPrefeneces(sender: NSMenuItem) {
        preferencesController?.showWindow(sender)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

func splitStringToLines(_ str: String, _ approximateLength: Int) -> String {
    var lines: [String] = []
    var startIndex = str.startIndex
    var midIndex = str.startIndex
    while (midIndex != str.endIndex) {
        str.formIndex(&midIndex, offsetBy: approximateLength, limitedBy: str.endIndex)
        var endIndex = str[midIndex...].firstIndex(of: " ") ?? str.endIndex
        lines.append(String(str[startIndex..<endIndex]))
        str.formIndex(&endIndex, offsetBy: 1, limitedBy: str.endIndex)
        startIndex = endIndex
        midIndex = endIndex
    }
    return lines.joined(separator: "\n")
}
