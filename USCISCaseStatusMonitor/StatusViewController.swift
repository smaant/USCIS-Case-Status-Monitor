//
//  StatusViewController.swift
//  USCISCaseStatusMonitor
//
//  Created by Anton Panferov on 4/29/19.
//  Copyright © 2019 Anton Panferov. All rights reserved.
//

import Cocoa
import WebKit

class StatusViewController: NSViewController {
    
    @IBOutlet weak var statusWebView: WKWebView!
    
    var prefs = Preferences()
    
    var webViewHeight: CGFloat = 0.0
    var windowHeight: CGFloat?
    var windowOriginY: CGFloat?
    
    class func loadFromNib() -> StatusViewController {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateController(withIdentifier: "StatusViewController") as! StatusViewController
    }
    
    func loadWebView() {
        let image = "<div style='width:100%;text-align:center;border:3px #000000;display:block'><img src='./Contents/Resources/my_logo.png' style='-webkit-transform:scale(0.7)'/></div>"
        let statusHtml = "<h1 style='color:#232b8d;font-family:helvetica;font-weight:500;font-size:25px;text-align:center;margin:10px 0;'>" + (prefs.currentStatus?.status ?? "") + "</h1>"
        let descriptionHtml = "<p style='font-family:georgia;color:#505050;font-size:14px;margin:10px;text-align:center'>" + (prefs.currentStatus?.description ?? "") + "</p>"
        let fullHtml = image + statusHtml + descriptionHtml
        
        statusWebView.loadHTMLString(fullHtml, baseURL: Bundle.main.bundleURL)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        webViewHeight = statusWebView.frame.size.height

        loadWebView()
    }
    
    func setWindowHeight(_ newHeight: CGFloat?) {
        if let window = self.view.window, let height = newHeight {
            let currentHeight = window.frame.size.height
            window.setFrame(NSRect(origin: NSPoint(x: window.frame.origin.x, y: window.frame.origin.y - (height - currentHeight)),
                                   size: CGSize(width: window.frame.size.width, height: height)),
                            display: true,
                            animate: true)
            self.windowHeight = window.frame.size.height
        }
    }
    
    func setWebViewHeight(_ newHeight: CGFloat) {
        statusWebView.setFrameSize(NSSize(width: statusWebView.frame.width,
                                          height: newHeight))
        webViewHeight = newHeight
    }
    
    override func viewWillAppear() {
        loadWebView()
        setWindowHeight(windowHeight)

        statusWebView.evaluateJavaScript("document.readyState", completionHandler: {(complete, error) in
            if complete != nil {
                self.statusWebView.evaluateJavaScript("document.body.scrollHeight", completionHandler: {(height, error) in
                    if let newHeight = height as? CGFloat, newHeight != self.webViewHeight {
                        let heightDiff = newHeight - self.webViewHeight
                        
                        self.setWebViewHeight(self.statusWebView.frame.height + heightDiff)

                        if let window = self.view.window {
                            self.setWindowHeight(window.frame.size.height + heightDiff)
                        }
                    }
                })
            }
        })
    }
}
