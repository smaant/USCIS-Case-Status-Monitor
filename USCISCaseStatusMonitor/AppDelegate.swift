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

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        if let button = statusItem.button {
            button.image = NSImage(named: "face")
        }
        
        switch USCISStatus().fetchCurrentStatus() {
        case .value(let currentStatus):
            menu.addItem(NSMenuItem(title: currentStatus.status, action: nil, keyEquivalent: ""))
            menu.addItem(NSMenuItem.separator())
            
            let item = NSMenuItem(title: "", action: nil, keyEquivalent: "")
            let description = splitStringToLines(
                currentStatus.description.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression),
                50)
            item.attributedTitle = NSAttributedString(string: description, attributes: nil)

            menu.addItem(item)

        case .error(_):
            menu.addItem(NSMenuItem(title: "Error: Unable to get case status. Check case number.", action: nil, keyEquivalent: ""))
        }
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
        
        
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
