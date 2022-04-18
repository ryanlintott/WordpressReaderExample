//
//  ContentView.swift
//  WordpressReaderExample
//
//  Created by Ryan Lintott on 2021-05-18.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            WordpressSiteView()
                .tabItem {
                    Label("Closure", systemImage: "network")
                }
            
            WordpressSiteAsyncView()
                .tabItem {
                    Label("Async", systemImage: "sparkles")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
