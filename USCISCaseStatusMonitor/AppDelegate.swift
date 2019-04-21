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
    
    let updateInterval = 60.0
    let prefs = Preferences()
    
    let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
    var preferencesController: NSWindowController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        if let button = statusItem.button {
            button.image = NSImage(named: "face")
        }
        
        menu.addItem(NSMenuItem(title: "", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Preferences...", action: #selector(showPrefeneces(sender:)), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem.menu = menu
        
        updateStatus()
        Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { (timer) in
            self.updateStatus()
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("PrefsChanged"), object: nil, queue: nil) { (notification) in
            self.updateStatus()
        }
        
        preferencesController = storyboard.instantiateController(withIdentifier: "PreferencesWindowController") as? NSWindowController
    }
    
    func updateStatus() {
        switch USCISStatus().fetchCurrentStatus(caseNumber: prefs.caseNumber ?? "") {
        case .value(let currentStatus):
            let description = splitStringToLines(
                currentStatus.description.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression),
                50)
            
            menu.item(at: 0)?.title = currentStatus.status
            menu.item(at: 2)?.attributedTitle = NSAttributedString(string: description, attributes: nil)
            menu.item(at: 2)?.isHidden = false
            
        case .error(_):
            menu.item(at: 0)?.title = "Error: Unable to get case status. Check case number."
            menu.item(at: 2)?.title = ""
            menu.item(at: 2)?.isHidden = true
        }
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
