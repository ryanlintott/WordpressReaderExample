//
//  WordpressSiteAsyncView.swift
//  Wordhord
//
//  Created by Ryan Lintott on 2022-03-29.
//

import SwiftUI
import WordpressReader

enum WordpressSiteAsyncViewTab: String {
    case posts, site, pages, categories
}

struct WordpressSiteAsyncView: View {
    @StateObject var siteManager = WordpressSiteAsyncManager(site: .wordhord)
    @State private var selection: WordpressSiteAsyncViewTab = .posts
    
    var body: some View {
        if #available(iOS 15.0, *) {
            tabView
                .task {
                    await siteManager.loadRecentThenAll()
                }
        } else {
            tabView
                .onAppear {
                    Task {
                        await siteManager.loadRecentThenAll()
                    }
                }
        }
    }
    
    var tabView: some View {
        TabView(selection: $selection) {
            WordpressItemListView(title: "Posts", items: siteManager.posts.sorted(by: { $0.date_gmt > $1.date_gmt }))
                .tabItem {
                    Label("Posts", systemImage: "globe")
                }
                .tag(WordpressSiteAsyncViewTab.posts)
            
            WordpressItemListView(title: "Pages", items: siteManager.pages.sorted(by: { $0.date_gmt > $1.date_gmt }))
                .tabItem {
                    Label("Pages", systemImage: "doc.plaintext")
                }
                .tag(WordpressSiteAsyncViewTab.pages)
            
            WordpressItemListView(title: "Categories", items: siteManager.categories)
                .tabItem {
                    Label("Categories", systemImage: "tag")
                }
                .tag(WordpressSiteAsyncViewTab.categories)
            
            WordpressSettingsView(settings: siteManager.settings)
                .tabItem {
                    Label("Site", systemImage: "gear")
                }
                .tag(WordpressSiteAsyncViewTab.site)
        }
    }
}

struct WordpressSiteAsyncView_Previews: PreviewProvider {
    static var previews: some View {
        WordpressSiteAsyncView()
    }
}
