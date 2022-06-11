//
//  AppDelegate.swift
//  macsplit
//
//  Created by Oliver LI on 6/10/22.
//
import Foundation

import SwiftUI
import AppKit

func truncate(num: Double, place: Double) -> Double {
    let pow = pow(10, Double(place))
    return (num * pow).rounded() / pow
}

func getStringFromSeconds(time: Double) -> String {
    let wholeTime = Int(time.rounded())
    // mere seconds
    if time < 60 {
        return String(format: "%.1f", time)
        // minutes
    } else if time < 60 * 60 {
        // see https://stackoverflow.com/a/33447385 for an explanation of why we're using %04.1f
        return "\(String(wholeTime/60)):\(String(format: "%04.1f", time.truncatingRemainder(dividingBy:60.0)))"
        // hours
    } else {
        return "\(String(wholeTime/3600)):\(String(format: "%02d", wholeTime/60%60)):\(String(format: "%04.1f", time.truncatingRemainder(dividingBy: 60.0)))"
    }
}

// See https://developer.apple.com/documentation/swiftui/nsapplicationdelegateadaptor
class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    
    // see https://caseybrant.com/2019/02/20/macos-menu-bar-extras.html
    @Published var statusBarItem: NSStatusItem!
    
    // timer code, see https://medium.com/macoclock/how-to-make-a-macos-menu-bar-app-bfdbbcd76077
    @Published var lastDate: Date = Date()
    @Published var time: TimeInterval = 0.0
    var timer: Timer?
    
    func init_timer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
            self.refresh()
        })
    }
    
    deinit {
        timer?.invalidate()
    }
    
    // see https://maheshsai252.medium.com/updating-swiftui-view-for-every-x-seconds-559360ce3b4a
    // this is basically just for updating the status bar, every 1 second. Ideally we have this running livesplit style, every hundredth of a millisedcond
    func refresh() {
        // update time
        time -= lastDate.timeIntervalSinceNow;
        lastDate = Date()
        // update statusbar
        
        let font = NSFont.monospacedDigitSystemFont(ofSize: 14.0, weight: NSFont.Weight.regular)
        let attributedString = NSAttributedString(string: getStringFromSeconds(time: time), attributes: [NSAttributedString.Key.font: font])
        statusBarItem.button?.attributedTitle = attributedString
        
//        statusBarItem.button!.title = getStringFromSeconds(time: time)
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let window = NSApplication.shared.windows.first {
            window.close()
        }
        // Insert code here to initialize your application
        let statusBar = NSStatusBar.system
        
        statusBarItem = statusBar.statusItem(
            // for literally 0 reason, the only values that are valid here are squarelength or variable, so we just set the actual length we want later
            withLength: NSStatusItem.variableLength
        )
        // statusBarItem.length = CGFloat(5.0)
        setupMenus()
        
//        see https://developer.apple.com/forums/thread/21474
        let font = NSFont.monospacedDigitSystemFont(ofSize: 14.0, weight: NSFont.Weight.regular)
        let attributedString = NSAttributedString(string: "0", attributes: [NSAttributedString.Key.font: font])
        statusBarItem.button?.attributedTitle = attributedString
        
        init_timer()
    }
    
    // see https://sarunw.com/posts/how-to-make-macos-menu-bar-app/
    func setupMenus() {
        let menu = NSMenu()
        
        // 2
        let startStop = NSMenuItem(title: "Start/Stop", action: #selector(didTapStartStop) , keyEquivalent: "p")
        startStop.allowsKeyEquivalentWhenHidden = true
        
        menu.addItem(startStop)
        
        let reset = NSMenuItem(title: "Reset", action: #selector(didTapReset) , keyEquivalent: "r")
        menu.addItem(reset)
        
        menu.addItem(NSMenuItem.separator())
        
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        // 3
        statusBarItem.menu = menu
        
        
    }
    
    
    @objc func didTapStartStop() {
        if let timerExisting = timer {
            if timerExisting.isValid {
                timerExisting.invalidate()
            } else {
                lastDate = Date()
                init_timer()
            }
        }
    }
    
    @objc func didTapReset() {
        timer?.invalidate()
        time = 0.0
        statusBarItem.button!.title = "0"
    }
    
    //    func application(
    //        _ application: NSApplication,
    //        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    //    ) {
    //    }
}
