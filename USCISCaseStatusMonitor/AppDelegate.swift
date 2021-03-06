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
    
    let popover = NSPopover()
    
    let dateFormater = DateFormatter()
    
    let updateInterval = 600.0
    var prefs = Preferences()
    var currentStatus: CaseStatus?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        dateFormater.dateFormat = "MM/dd/YYYY, h:mm:ss a"
        
        if let button = statusItem.button {
            button.image = NSImage(named: "unchanged")
            button.action = #selector(togglePopover(sender:))
        }
        
        updateStatus()
        Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { (timer) in
            self.updateStatus()
        }
        
        popover.behavior = .transient
        popover.animates = false
        popover.contentViewController = PopoverViewController.loadFromNib()
        popover.contentViewController?.loadView()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("PrefsChanged"), object: nil, queue: nil) { (notification) in
            self.prefs.lastAcknowledgedStatus = nil
            self.updateStatus()
        }
    }
    
    @objc func togglePopover(sender: NSStatusBarButton) {
        if popover.isShown {
            popover.performClose(sender)
        } else {
            if let button = statusItem.button {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
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
//            ackMenuItem.isEnabled = false
        } else {
            statusItem.button?.image = NSImage(named: "changed")
//            ackMenuItem.isEnabled = true
        }
    }
    
    func updateStatus() {
        switch USCISStatus().fetchCurrentStatus(caseNumber: prefs.caseNumber ?? "") {
        case .value(let currentStatus):
            if prefs.currentStatus != currentStatus {
                prefs.currentStatus = currentStatus
                NotificationCenter.default.post(name: NSNotification.Name("StatusChanged"), object: nil)
            }
            self.currentStatus = currentStatus
            updateMenuBarIcon(newStatus: currentStatus)
            
        case .error(_):
            self.currentStatus = nil
            updateMenuBarIcon(newStatus: nil)
//            statusMenuItem.title = "Error: Unable to get case status. Check case number."
//            descriptionMenuItem.isHidden = true
        }
        
        prefs.lastSyncedAt = dateFormater.string(from: Date())
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
