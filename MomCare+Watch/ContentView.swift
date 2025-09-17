//
//  ContentView.swift
//  MomCare+ Watch Watch App
//
//  Created by Aryan Singh on 17/09/25.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var watchConnector: WatchConnector = .init()

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}
