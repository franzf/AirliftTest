//
//  PreferencesWindow.swift
//  AirliftTest
//

import Cocoa

class PreferencesWindow: NSWindowController {
    
    @IBOutlet weak var serverField: NSTextField!
    
    @IBOutlet weak var passwordField: NSSecureTextField!
    
    @IBAction func saveButton(_ sender: Any) {
        airliftServerUrl = self.serverField.stringValue
        airliftServerPassword = self.passwordField.stringValue
        defaults.set(airliftServerUrl, forKey: "Server")
        defaults.set(airliftServerPassword, forKey: "Password")
        close()
    }
    
    override var windowNibName : String! {
        return "PreferencesWindow"
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps:true)
        
        if let savedServer = defaults.string(forKey: "Server") {
            serverField.stringValue = savedServer
        }
        if let savedPassword = defaults.string(forKey: "Password") {
            passwordField.stringValue = savedPassword
        }

    }
    
    func windowWillClose(notification: NSNotification) {

    }
    
}
