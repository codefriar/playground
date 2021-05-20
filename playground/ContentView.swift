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
    
    var body: some View {
        VStack {
//            Text("Loading...")
            if nil != window {
                MainView(screen: Screen2(window: window!))
            }
        }.background(WindowGetter(window: $window))
    }
}

struct MainView: View {
    let screen: Screen2
    
    //var image = CGImage(windowListFromArrayScreenBounds: CGRect(x: 0,y: 0,width: 0,height: 0), windowArray: nil, imageOption: .nil)
    init(screen: Screen2){
        self.screen = screen
    }
    
    var body: some View {
        VStack {
//            Text("MainView with Window: \(screen.window)")
            Image(nsImage: self.screen.image)
        }.frame(width: 400, height: 400)
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
