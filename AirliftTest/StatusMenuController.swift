//
//  StatusMenuController.swift
//  AirliftTest
//

import Foundation
import Cocoa
import Alamofire
import AppKit
import MASShortcut
import ScriptingBridge

var preferencesWindow: PreferencesWindow!

class StatusMenuController: NSObject {
    
    @IBOutlet weak var statusMenu: NSMenu!
    
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    
    override func awakeFromNib() {
        statusItem.menu = statusMenu
        let icon = NSImage(named: "statusIcon")
        icon?.isTemplate = true
        statusItem.image = icon
        statusItem.menu = statusMenu
        preferencesWindow = PreferencesWindow()
        
        let finderShortcut = MASShortcut.init(keyCode: UInt(kVK_ANSI_D), modifierFlags: UInt(NSEventModifierFlags.option.rawValue))
        
        MASShortcutMonitor.shared().register(finderShortcut, withAction: {
            let finderApp : AnyObject = SBApplication(bundleIdentifier:"com.apple.finder")!
            let finderObject = finderApp.selection as! SBObject
            if let selection = finderObject.get() as? [SBObject] {
                selection.forEach { item in
                    let url = URL(string: item.value(forKey:"URL") as! String)!
                    if defaults.string(forKey: "Server") != nil {
                        self.uploadAndCopyToPasteboard(fileURL: url)
                    } else {
                        self.configAlert()
                    }
                }
            }
        })
        
        let optShift4Shortcut = MASShortcut.init(keyCode: UInt(kVK_ANSI_4), modifierFlags: UInt(NSEventModifierFlags.option.rawValue + NSEventModifierFlags.shift.rawValue))
        
        MASShortcutMonitor.shared().register(optShift4Shortcut, withAction: {
            let tempDir = NSTemporaryDirectory()
            let fileName = "Screenshot.png"
            let tempFileUrl = NSURL.fileURL(withPathComponents: [tempDir, fileName])!
            let tempFilePath:String = tempFileUrl.path
            Process.launchedProcess(launchPath: "/usr/sbin/screencapture", arguments:["-i", tempFilePath]).waitUntilExit()
            if defaults.string(forKey: "Server") != nil {
                self.uploadAndCopyToPasteboard(fileURL: tempFileUrl)
            } else {
                self.configAlert()
            }
        })
    }
    
    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared().terminate(self)
    }
        
    @IBAction func settingsMenuClicked(_ sender: NSMenuItem) {
        preferencesWindow.showWindow(nil)
    }
    
    @IBAction func uploadMenuItemClicked(_ sender: NSMenuItem) {
        if defaults.string(forKey: "Server") != nil {
            let fileURL = openFilePanel()
            uploadAndCopyToPasteboard(fileURL: fileURL)
        } else {
            configAlert()
        }
    }

    func configAlert() -> Void {
        let configAlert: NSAlert = NSAlert()
        configAlert.messageText = "Airlift hasn't been configured yet."
        configAlert.informativeText = "Open the app preferences to add a server."
        configAlert.addButton(withTitle: "Preferences...")
        configAlert.addButton(withTitle: "Cancel")
        let userSelection = configAlert.runModal()
        if userSelection == NSAlertFirstButtonReturn {
            preferencesWindow.showWindow(nil)
        }
        return
    }
    
    func openFilePanel() -> URL {
        let openpanel = NSOpenPanel()
        openpanel.title                   = "Upload";
        openpanel.showsResizeIndicator    = true;
        openpanel.showsHiddenFiles        = false;
        openpanel.allowsMultipleSelection = false;
        
        if (openpanel.runModal() == NSModalResponseOK) {
            return(openpanel.url)!
        }
        else {
            return URL(string: "invalid:///")!
        }
    }
    
    func uploadAndCopyToPasteboard(fileURL: URL) {
        
        let fileName = (fileURL).lastPathComponent
        
        let headers: HTTPHeaders = [
            "X-Airlift-Password":airliftServerPassword,
            "X-Airlift-Filename":fileName
        ]
        
        Alamofire.upload(fileURL, to: airliftServerUrl, headers: headers).responseJSON { response in
            if let rawResponse = response.result.value {
                if let responseDictionary = rawResponse as? [String: Any] {
                    if let urlWithoutScheme = responseDictionary["URL"] as? String {
                        let serverUrlAsUrl = URL(string: airliftServerUrl)
                        let serverScheme = (serverUrlAsUrl!).scheme
                        let finalUrl = (serverScheme as String!) + "://" + urlWithoutScheme
                        let pasteBoard = NSPasteboard.general()
                        pasteBoard.clearContents()
                        pasteBoard.setString(finalUrl, forType: NSStringPboardType)
                        self.sendNotification(passedFinalUrl: finalUrl)
                    }
                }
            }
        }
        
    }
    
    func sendNotification(passedFinalUrl: String) {
        let notification = NSUserNotification.init()
        notification.title = passedFinalUrl
        notification.informativeText = "Uploaded with Airlift"
        notification.userInfo = ["urlInsideUserInfo" : passedFinalUrl]
        NSUserNotificationCenter.default.deliver(notification)
    }
    
}
