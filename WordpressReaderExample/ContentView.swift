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
            WordpressSiteAsyncView()
                .tabItem {
                    Label("Async", systemImage: "sparkles")
                }
            
            WordpressSiteView()
                .tabItem {
                    Label("Closure", systemImage: "network")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
