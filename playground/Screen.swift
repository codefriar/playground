//
//  Screen.swift
//
//
//  Created by Rudy Richter on 5/18/21.
//

import Foundation
#if os(macOS)
import AppKit

class Screen: NSObject {
    static let scanInterval: TimeInterval = 0.5
    
    static var available: Bool {
        #if os(iOS)
        return false
        #elseif os(macOS)
        return true
        #else
        #error("unknown architeture")
        #endif
    }
    
    fileprivate var scanView: NSView
    fileprivate var scanTimer: Timer?
    
    init(view: NSView) {
        scanView = view
        super.init()
    }
    
    func startScanning() {
        if canRecord == false,
           let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture") {
            NSWorkspace.shared.open(url)
        }
        else {
            self.scanTimer?.invalidate()
            self.scanTimer = Timer.scheduledTimer(timeInterval: Self.scanInterval, target: self, selector: #selector(snapshot(_:)), userInfo: nil, repeats: true)
        }
    }
    
    func stopScanning() {
        self.scanTimer?.invalidate()
        self.scanTimer = nil
    }
    
    @objc func snapshot(_ timer: Timer) {
        guard let screenImage = self.imageOfScreen(below: self.scanView) else {
            return
        }
        
        //        self.evaluate(image: screenImage)
    }
    
    func imageOfScreen(below view: NSView ) -> CGImage? {
        guard let window = view.window else {
            return nil
        }
        
        let windowId = CGWindowID(window.windowNumber)
        let windowOption: CGWindowListOption = .optionOnScreenBelowWindow
        let imageOption: CGWindowImageOption = .boundsIgnoreFraming
        
        let windowCoordinates = view.convert(view.bounds, to: nil)
        let screenCoordinates = window.convertToScreen(windowCoordinates)
        let q1Toq4Coordinates = Q1ToQ4Rect(screenCoordinates)
        return CGWindowListCreateImage(q1Toq4Coordinates, windowOption, windowId, imageOption)
    }
    
    // Converts from Q1 (Cocoa) to Q4 (Carbon).
    // Graciously provided by Rudy Richter. Works better than all other Cocoa->Carbon converts I've seen so far. They usually don't take into consideration the possibility that the secondary display could be under the primary.
    fileprivate func Q1ToQ4Rect(_ inBounds: CGRect) -> CGRect {
        let screens = NSScreen.screens
        guard screens.count > 0,
              let primaryScreen = screens.first else {
            return inBounds
        }
        
        var result = inBounds
        result.origin.y = (inBounds.maxY - primaryScreen.frame.maxY) * -1.0
        return result;
    }
    
    fileprivate var canRecord: Bool {
        if #available(macOS 10.15, *) {
            let ourProcessIdentifier = NSRunningApplication.current.processIdentifier
            guard let windowList = CGWindowListCopyWindowInfo(.optionOnScreenOnly, kCGNullWindowID) as? [[AnyHashable : Any]] else {
                return false
            }
            
            for window in windowList {
                
                guard let processIdentifier = window[kCGWindowOwnerPID] as? Int32,
                      processIdentifier != ourProcessIdentifier,
                      let applicationForWindow = NSRunningApplication(processIdentifier: processIdentifier) else {
                    continue
                }
                
                if window[kCGWindowName] != nil,
                   applicationForWindow.executableURL?.lastPathComponent != "Dock" {
                    return true
                }
            }
            return false
        }
        else {
            return true
        }
    }
}

#endif
