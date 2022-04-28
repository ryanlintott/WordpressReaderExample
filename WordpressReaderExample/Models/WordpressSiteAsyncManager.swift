//
//  WordpressSiteAsyncManager.swift
//  WordpressReaderExample
//
//  Created by Ryan Lintott on 2022-03-29.
//

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
    @Published var error: String? = nil
    
    init(site: WordpressSite) {
        self.site = site
    }
    
    func loadRecentThenAll(recentIfAfterDate date: Date = Date().addingTimeInterval(-7 * 24 * 60 * 60)) async {
        let asyncStart = Date()
        
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await self.loadSettings()
                print("Settings: \(Date().timeIntervalSince(asyncStart))")
            }
            
            group.addTask {
                await self.loadCategories()
                print("Categories: \(Date().timeIntervalSince(asyncStart))")
            }
            
            group.addTask {
                await self.loadPosts(queryItems: [.postedAfter(date)])
                print("RecentPosts: \(Date().timeIntervalSince(asyncStart))")
            }
            
            group.addTask {
                await self.loadPosts(queryItems: [.postedBefore(date)])
                print("RemainingPosts: \(Date().timeIntervalSince(asyncStart))")
            }
            
            group.addTask {
                await self.loadPages()
                print("Pages: \(Date().timeIntervalSince(asyncStart))")
            }
        }
        print("All done")
    }
    
    func loadAll() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadSettings() }
            group.addTask { await self.loadCategories() }
            group.addTask { await self.loadPosts() }
            group.addTask { await self.loadPages() }
        }
        print("All done")
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
    
    /// Loads posts using an async stream
    /// - Parameter queryItems: Set of query items
    /// - Parameter maxPages: Max pages of posts to load
    func loadPosts(queryItems: Set<WordpressQueryItem> = [], maxPages: Int? = nil) async {
        var request = WordpressPost.request(queryItems: queryItems)
        if let maxPages = maxPages {
            request.maxPages = maxPages
        }
        do {
            for try await post in try await site.postStream(request) {
                self.posts.update(with: post)
            }
        } catch let error {
            processError(error)
        }
    }
    
    // Loads up to 100 pages without batching
    func loadPages(queryItems: Set<WordpressQueryItem> = []) async {
        do {
            let pages = try await site.fetchPages(.init(queryItems: queryItems))
            self.pages = Set(pages)
        } catch let error {
            processError(error)
        }
        
    }
    
    // Loads all categories using batching
    func loadCategories() async {
        do {
            categories = try await site.fetchCategories()
        } catch let error {
            processError(error)
        }
    }
    
    func processError(_ error: Error) {
        self.error = errorString(error)
    }
    
    func errorString(_ error: Error) -> String {
        switch error {
        case NetworkError.badURL:
            return "Bad URL"
        case NetworkError.requestFailed:
            return "Network problems: \(error.localizedDescription)"
        case NetworkError.unknown(let description):
            return "Unknown network error: \(description)"
        case is DecodingError:
            return "Decoding error: \(error.localizedDescription)"
        case is WordpressError:
            return "Wordpress error: \(error.localizedDescription)"
        default:
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}
