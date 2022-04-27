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
    @State private var loading: Bool = false
    
    var body: some View {
        TabView(selection: $selection) {
            WordpressItemListView(title: "Posts", items: siteManager.posts.sorted(by: { $0.date_gmt > $1.date_gmt }), loading: loading)
                .tabItem {
                    Label("Posts", systemImage: "globe")
                }
                .tag(WordpressSiteViewTab.posts)
            
            WordpressItemListView(title: "Pages", items: siteManager.pages.sorted(by: { $0.date_gmt > $1.date_gmt }), loading: loading)
                .tabItem {
                    Label("Pages", systemImage: "doc.plaintext")
                }
                .tag(WordpressSiteViewTab.pages)
            
            WordpressItemListView(title: "Categories", items: siteManager.categories, loading: loading)
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
            loading = true
            siteManager.loadRecentThenAll {
                DispatchQueue.main.async {
                    loading = false
                }
            }
        }
    }
}

struct WordpressSiteView_Previews: PreviewProvider {
    static var previews: some View {
        WordpressSiteView()
    }
}
