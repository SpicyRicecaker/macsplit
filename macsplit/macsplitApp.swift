//
//  macsplitApp.swift
//  macsplit
//
//  Created by Oliver LI on 6/10/22.
//

import SwiftUI

@main
struct macsplitApp: App {
    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
//            ContentView()
            ZStack {
                  EmptyView()
            }.hidden()
        }
    }
}

