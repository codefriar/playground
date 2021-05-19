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
    
    init(){
//        NotificationCenter.default.addObserver(forName: NSView.frameDidChangeNotification, object: nil, queue: nil) { (notification) in
//            print(notification)
//        }
    }
    
}
