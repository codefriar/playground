//
//  Screen2.swift
//  playground
//
//  Created by Kevin Poorman on 5/19/21.
//

import Foundation
import SwiftUI
import Combine
import NotificationCenter

class Screen2: ObservableObject {
    @Published var origin: (x:CGFloat, y:CGFloat) = (0.0, 0.0)
    @Published var heightWidth: (x:CGFloat, y:CGFloat) = (0.0, 0.0)
    @Published var frame: CGRect = .zero
    @Published var image = NSImage()
    
    var subscriptions = Set<AnyCancellable>()
    var window: NSWindow
    
    init(window: NSWindow){
        self.window = window
        Timer.publish(every: 1, on: .main, in: .default)
            .autoconnect()
            .sink { _ in
                let options = CGWindowListOption(arrayLiteral: CGWindowListOption.excludeDesktopElements, CGWindowListOption.optionOnScreenOnly)
                let windowListInfo = CGWindowListCopyWindowInfo(options, CGWindowID(0))
                let infoList = windowListInfo as NSArray? as? [[String: AnyObject]]
                if let il = infoList {
                    for win in il {
                        if let name = win["kCGWindowOwnerName"] as? String,
                           let bounds = win["kCGWindowBounds"]{
                            if name == "playground" {
                                print("Bounds are: \(bounds)")
                            }
                        }
                    }
                }
                let windowId = CGWindowID(self.window.windowNumber)
                let windowOption: CGWindowListOption = .optionOnScreenBelowWindow
                let imageOption: CGWindowImageOption = .boundsIgnoreFraming
                
                if let windowCoordinates = self.window.contentView?.bounds {
                    let screenCoordinates = self.window.convertToScreen(windowCoordinates)
                    let q1Toq4Coordinates = self.Q1ToQ4Rect(screenCoordinates)
                    let image = CGWindowListCreateImage(q1Toq4Coordinates, windowOption, windowId, imageOption)
                    if let img = image {
                        self.image = NSImage(cgImage: img, size: .zero)
                        print(self.image.isValid)
                    }
                } 
            }
            .store(in: &subscriptions)
        
    }
    
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
    
}
