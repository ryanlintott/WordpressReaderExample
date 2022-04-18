//
//  WordpressSiteAsyncManager.swift
//  WordpressReaderExample
//
//  Created by Ryan Lintott on 2022-03-29.
//

import Foundation

import Foundation
import WordpressReader

@MainActor
class WordpressSiteAsyncManager: ObservableObject {
    let site: WordpressSite
    
    @Published var singlePost: WordpressPost? = nil
    @Published var posts: Set<WordpressPost> = []
    @Published var pages: Set<WordpressPage> = []
    @Published var categories: [WordpressCategory] = []
    @Published var settings: WordpressSettings? = nil
    @Published var loading = false
    
    init(site: WordpressSite) {
        self.site = site
    }
    
    func loadRecentThenAll(recentIfAfterDate date: Date = Date().addingTimeInterval(-259200)) async {
        let asyncStart = Date()
        await loadSettings()
        print("Settings: \(Date().timeIntervalSince(asyncStart))")

        await loadCategories()
        print("Categories: \(Date().timeIntervalSince(asyncStart))")

        Task(priority: .high) {
            await loadPosts(queryItems: [.postedAfter(date)])
            print("RecentPosts: \(Date().timeIntervalSince(asyncStart))")
        }

        Task {
            await loadPosts(queryItems: [.postedBefore(date)])
            print("RemainingPosts: \(Date().timeIntervalSince(asyncStart))")
        }
        
        Task {
            await loadPages()
            print("Pages: \(Date().timeIntervalSince(asyncStart))")
        }
        
        //Settings: 0.22335398197174072
        //Categories: 0.9343689680099487
        //RecentPosts: 1.6450740098953247
        //RecentPages: 1.8282029628753662
        //RemainingPosts: 12.928786993026733
        //RemainingPages: 14.660529971122742
        
    }
    
    func loadAll(postQueryItems: [WordpressQueryItem] = [], pageQueryItems: [WordpressQueryItem] = []) async {
        await loadSettings()
        await loadCategories()
        await loadPosts(queryItems: postQueryItems)
        await loadPages(queryItems: pageQueryItems)
    }
    
    func loadSettings() async {
        do {
            settings = try await site.fetchSettings()
        } catch let error {
            processError(error)
        }
    }
    
    // Loads a single post by id
    func loadPost(id: Int) async {
        do {
            singlePost = try await site.fetchById(WordpressPost.self, id: id)
        } catch let error {
            processError(error)
        }
    }
    
    // Loads posts
    func loadPosts(queryItems: [WordpressQueryItem] = []) async {
        let request = WordpressRequest(queryItems: queryItems)
        do {
            for try await posts in try await site.postStream(request) {
                self.posts = self.posts.union(posts)
            }
        } catch let error {
            processError(error)
        }
    }
    
    // Loads up to 100 pages without batching
    func loadPages(queryItems: [WordpressQueryItem] = []) async {
        let request = WordpressRequest(queryItems: queryItems)
        let pages = await fetchItems(WordpressPage.self, request: request)
        self.pages = self.pages.union(pages)
    }
    
    // Loads all categories using batching
    func loadCategories() async {
        categories = await fetchItems(WordpressCategory.self)
    }
    
    internal func fetchItems<T: WordpressItem>(_ type: T.Type, request: WordpressRequest = .init()) async -> [T] {
        do {
            return try await site.items(type, request: request)
        } catch let error {
            processError(error)
            return []
        }
    }
    
    func processError(_ error: Error) {
        switch error {
        case NetworkError.badURL:
            print("Bad URL")
        case NetworkError.requestFailed:
            print("Network problems: \(error.localizedDescription)")
        case NetworkError.unknown(let description):
            print("Unknown network error: \(description)")
        case is DecodingError:
            print("Decoding error: \(error.localizedDescription)")
        case is WordpressError:
            print("Wordpress error: \(error.localizedDescription)")
        default:
            print("Unknown error: \(error.localizedDescription)")
        }
    }
}
