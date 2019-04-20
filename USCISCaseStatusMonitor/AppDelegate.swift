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
//            button.action = #selector(showWeather(sender:))
        }
        
        switch USCISStatus().fetchCurrentStatus() {
        case .value(let currentStatus):
            menu.addItem(NSMenuItem(title: currentStatus.status, action: nil, keyEquivalent: ""))
            menu.addItem(NSMenuItem.separator())
            
            let item = NSMenuItem(title: "", action: nil, keyEquivalent: "")
            let description = currentStatus.description.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            var lines: [String] = []
            let offset = 50
            var startIndex = description.startIndex
            var midIndex = description.startIndex
            while (midIndex != description.endIndex) {
                description.formIndex(&midIndex, offsetBy: 50, limitedBy: description.endIndex)
                var endIndex = description[midIndex...].firstIndex(of: " ") ?? description.endIndex
                lines.append(String(description[startIndex..<endIndex]))
                description.formIndex(&endIndex, offsetBy: 1, limitedBy: description.endIndex)
                startIndex = endIndex
                midIndex = endIndex
            }
            
            item.attributedTitle = NSAttributedString(string: lines.joined(separator: "\n"), attributes: nil)

            menu.addItem(item)

        case .error(let error):
            print(error)
        }
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
        
        
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @objc func showWeather(sender: NSStatusBarButton) {
        print("Sunshine")
    }    
}

