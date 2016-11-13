//
//  AppDelegate.swift
//  AirliftTest
//

import Cocoa
import AppKit

var airliftServerUrl = ""
var airliftServerPassword = ""

let defaults = UserDefaults.standard

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let savedServer = defaults.string(forKey: "Server") {
            airliftServerUrl = savedServer
        }
        if let savedPassword = defaults.string(forKey: "Password") {
            airliftServerPassword = savedPassword
        }
        NSUserNotificationCenter.default.delegate = self;
    }
   
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }

    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        let urlAsAny = notification.userInfo!["urlInsideUserInfo"]
        let urlAsUrl = URL(string: urlAsAny as! String)
        NSWorkspace.shared().open(urlAsUrl!)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

}

