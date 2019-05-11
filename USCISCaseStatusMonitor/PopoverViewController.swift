//
//  StatusViewController.swift
//  USCISCaseStatusMonitor
//
//  Created by Anton Panferov on 4/29/19.
//  Copyright © 2019 Anton Panferov. All rights reserved.
//

import Cocoa
import WebKit

class PopoverViewController: NSViewController {
    
    @IBOutlet weak var containerView: NSView!
    
    var tabViewController: NSViewController?
    
    class func loadFromNib() -> PopoverViewController {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateController(withIdentifier: "PopoverViewController") as! PopoverViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabViewController = storyboard!.instantiateController(withIdentifier: "TabViewController") as? NSViewController
        addChild(tabViewController!)
        tabViewController?.view.frame.origin = CGPoint(x: 0, y: 0)
        tabViewController?.view.frame.size = CGSize(width: view.frame.size.width, height: view.frame.size.height - 5)
        containerView.addSubview(tabViewController!.view)
    }
    
    override func viewWillLayout() {
        let viewSize = view.frame.size
        tabViewController?.view.setFrameSize(CGSize(width: viewSize.width, height: viewSize.height - 5))
    }
}
