//
//  WordpressSiteManager.swift
//  WordpressReaderExample
//
//  Created by Ryan Lintott on 2021-05-18.
//

import Foundation
import WordpressReader

class WordpressSiteManager: ObservableObject {
    let site: WordpressSite
    
    @Published var singlePost: WordpressPost? = nil
    @Published var posts = [WordpressPost]()
    @Published var pages = [WordpressPage]()
    @Published var categories = [WordpressCategory]()
    @Published var settings: WordpressSettings? = nil
    @Published var loading = false
    
    init(site: WordpressSite) {
        self.site = site
    }
    
    func loadRecentThenAll(recentIfAfterDate date: Date = Date().addingTimeInterval(-259200), completion: (() -> Void)? = nil) {
        let asyncStart = Date()
        loadSettings {
            let asyncSettings = Date().timeIntervalSince(asyncStart)
            self.loadCategories {
                let asyncCategories = Date().timeIntervalSince(asyncStart)
                self.loadPosts() {
                    let asyncPosts = Date().timeIntervalSince(asyncStart)
                    self.loadPages() {
                        let asyncPages = Date().timeIntervalSince(asyncStart)
                        completion?()
                        print("""
                            Settings: \(asyncSettings)
                            Categories: \(asyncCategories)
                            Posts: \(asyncPosts)
                            Pages: \(asyncPages)
                        """)
                        
                        //Settings: 0.2008359432220459
                        //Categories: 0.6105250120162964
                        //Posts: 1.9895210266113281
                        //Pages: 2.7375659942626953
                    }
                }
            }
        }
    }
    
    func loadAll(perPage: Int? = nil, maxNumPages: Int? = nil, completion: (() -> Void)? = nil) {
        loadSettings {
            self.loadCategories {
                self.loadPosts(perPage: perPage, maxNumPages: maxNumPages) {
                    self.loadPages(perPage: perPage, maxNumPages: maxNumPages) {
                        completion?()
                    }
                }
            }
        }
    }
    
    func loadSettings(completion: (() -> Void)? = nil) {
        site.fetchSettings { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let settings):
                    self.settings = settings
                case .failure(let error):
                    print("Error loadSettings")
                    self.processError(error)
                }
                completion?()
            }
        }
    }
    
    // Loads a single post by id
    func loadPost(id: Int, completion: (() -> Void)? = nil) {
        site.fetchById(WordpressPost.self, id: id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let post):
                    self.singlePost = post
                case .failure(let error):
                    print("Error loadPost")
                    self.processError(error)
                }
                completion?()
            }
        }
    }
    
    // Loads posts with batching
    func loadPosts(perPage: Int? = nil, maxNumPages: Int? = nil, completion: (() -> Void)? = nil) {
        var allPosts: [WordpressPost] = []
        
        site.fetchContent(WordpressPost.self, perPage: perPage, maxNumPages: maxNumPages) { result in
//            DispatchQueue.main.async {
                switch result {
                case .success(let posts):
                    allPosts += posts
                case .failure(let error):
                    print("Error loadPosts")
                    self.processError(error)
                }
//            }
        } completion: {
            DispatchQueue.main.async {
                self.posts = allPosts
            }
            completion?()
        }
    }
    
    // Loads pages with batching
    func loadPages(perPage: Int? = nil, maxNumPages: Int? = nil, completion: (() -> Void)? = nil) {
        var allPages: [WordpressPage] = []
        
        site.fetchContent(WordpressPage.self, perPage: perPage, maxNumPages: maxNumPages) { result in
//            DispatchQueue.main.async {
                switch result {
                case .success(let pages):
                    allPages += pages
                case .failure(let error):
                    print("Error loadPosts")
                    self.processError(error)
                }
//            }
        } completion: {
            DispatchQueue.main.async {
                self.pages = allPages
            }
            completion?()
        }
    }
    
    // Loads all categories using batching
    func loadCategories(completion: (() -> Void)? = nil) {
        site.fetchAllItems(WordpressCategory.self) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let categories):
                    self.categories = categories
                case .failure(let error):
                    print("Error loadCategories")
                    self.processError(error)
                }
                completion?()
            }
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
        default:
            print("Unknown error: \(error.localizedDescription)")
        }
    }
}
