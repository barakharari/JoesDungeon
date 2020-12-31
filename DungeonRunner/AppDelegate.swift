//
//  AppDelegate.swift
//  DungeonRunner
//
//  Created by Barak on 12/29/20.
//


import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if #available(OSX 10.12.1, *) {
            NSApplication.shared.isAutomaticCustomizeTouchBarMenuItemEnabled = true
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    
}
