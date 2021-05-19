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
                    Image(systemName: "globe")
                    Text("Posts")
                }
                .tag(WordpressSiteViewTab.posts)
            
            WordpressItemListView(title: "Pages", items: siteManager.pages)
                .tabItem {
                    Image(systemName: "doc.plaintext")
                    Text("Pages")
                }
                .tag(WordpressSiteViewTab.pages)
            
            WordpressItemListView(title: "Categories", items: siteManager.categories)
                .tabItem {
                    Image(systemName: "tag")
                    Text("Categories")
                }
                .tag(WordpressSiteViewTab.categories)
            
            WordpressSettingsView(settings: siteManager.settings)
                .tabItem {
                    Image(systemName: "gear")
                    Text("Site")
                }
                .tag(WordpressSiteViewTab.site)
        }
        .onAppear {
            siteManager.loadSettings()
            siteManager.loadPosts(perPage: 10, maxNumPages: 1)
            siteManager.loadPages(perPage: 10, maxNumPages: 1)
            siteManager.loadCategories()
        }
    }
}

struct WordpressSiteView_Previews: PreviewProvider {
    static var previews: some View {
        WordpressSiteView()
    }
}
