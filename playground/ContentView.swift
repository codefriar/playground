//
//  ContentView.swift
//  playground
//
//  Created by Kevin Poorman on 5/19/21.
//

import SwiftUI
import NotificationCenter
import CoreGraphics

struct ContentView: View {
    @State private var window: NSWindow?
    let screen = Screen2()
    
    var body: some View {
        VStack {
            Text("Loading...")
            if nil != window {
                MainView(store: Store(window: window!))
            }
        }.background(WindowGetter(window: $window))
    }
}

struct MainView: View {
    var image = CGImage(windowListFromArrayScreenBounds: CGRect(x: 0,y: 0,width: 0,height: 0), windowArray: nil, imageOption: .nil)
    init(store: Store){
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
        self.store = store
        
        let windowId = CGWindowID(self.store.window.windowNumber)
        let windowOption: CGWindowListOption = .optionOnScreenBelowWindow
        let imageOption: CGWindowImageOption = .boundsIgnoreFraming
        
        if let windowCoordinates = self.store.window.contentView?.bounds {
            let screenCoordinates = self.store.window.convertToScreen(windowCoordinates)
            let q1Toq4Coordinates = Q1ToQ4Rect(screenCoordinates)
            if let img = CGWindowListCreateImage(q1Toq4Coordinates, windowOption, windowId, imageOption) {
                self.image = img
            }
        }//view.convert(view.bounds, to: nil)
    }
    
    let store: Store
    
    var body: some View {
        VStack {
            Text("MainView with Window: \(store.window)")
            Image(nsImage: NSImage(cgImage: self.image, size: .zero))
        }.frame(width: 400, height: 400)
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

class Store {
    var window: NSWindow
    init(window: NSWindow) {
        self.window = window
    }
}

struct WindowGetter: NSViewRepresentable {
    @Binding var window: NSWindow?
    
    func makeNSView(context: Context) -> some NSView {
        let view = NSView()
        DispatchQueue.main.async {
            self.window = view.window
        }
        return view
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) {}
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
