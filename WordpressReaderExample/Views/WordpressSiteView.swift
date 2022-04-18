//
//  WordpressSiteView.swift
//  Wordhord
//
//  Created by Ryan Lintott on 2020-07-11.
//

import SwiftUI
import WordpressReader

enum WordpressSiteViewTab: String {
    case posts, site, pages, categories
}

struct WordpressSiteView: View {
    @StateObject var siteManager = WordpressSiteManager(site: .wordhord)
    @State private var selection: WordpressSiteViewTab = .posts
    
    var body: some View {
        TabView(selection: $selection) {
            WordpressItemListView(title: "Posts", items: siteManager.posts)
                .tabItem {
                    Label("Posts", systemImage: "globe")
                }
                .tag(WordpressSiteViewTab.posts)
            
            WordpressItemListView(title: "Pages", items: siteManager.pages)
                .tabItem {
                    Label("Pages", systemImage: "doc.plaintext")
                }
                .tag(WordpressSiteViewTab.pages)
            
            WordpressItemListView(title: "Categories", items: siteManager.categories)
                .tabItem {
                    Label("Categories", systemImage: "tag")
                }
                .tag(WordpressSiteViewTab.categories)
            
            WordpressSettingsView(settings: siteManager.settings)
                .tabItem {
                    Label("Site", systemImage: "gear")
                }
                .tag(WordpressSiteViewTab.site)
        }
        .onAppear {
            siteManager.loadRecentThenAll()
        }
    }
}

struct WordpressSiteView_Previews: PreviewProvider {
    static var previews: some View {
        WordpressSiteView()
    }
}
