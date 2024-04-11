//
//  WordpressSiteManager.swift
//  WordpressReaderExample
//
//  Created by Ryan Lintott on 2021-05-18.
//

import Foundation
import WordpressReader

@MainActor
class WordpressSiteManager: ObservableObject {
    let site: WordpressSite
    
    @Published var singlePost: WordpressPost? = nil
    @Published var posts: Set<WordpressPost> = []
    @Published var pages: Set<WordpressPage> = []
    @Published var categories = [WordpressCategory]()
    @Published var settings: WordpressSettings? = nil
    @Published var error: String? = nil
    
    init(site: WordpressSite) {
        self.site = site
    }
    
    func loadRecentThenAll(recentIfAfterDate date: Date = Date().addingTimeInterval(-7 * 24 * 60 * 60), completion: (@Sendable () -> Void)? = nil) {
        let asyncStart = Date()
        
        loadSettings {
            DispatchQueue.main.async {
                let asyncSettings = Date().timeIntervalSince(asyncStart)
                self.loadCategories {
                    let asyncCategories = Date().timeIntervalSince(asyncStart)
                    
                    DispatchQueue.main.async {
                        self.loadPosts() {
                            let asyncPosts = Date().timeIntervalSince(asyncStart)
                            
                            DispatchQueue.main.async {
                                self.loadPages() {
                                    let asyncPages = Date().timeIntervalSince(asyncStart)
                                    completion?()
                                    print("""
                                        Settings: \(asyncSettings)
                                        Categories: \(asyncCategories)
                                        Posts: \(asyncPosts)
                                        Pages: \(asyncPages)
                                    """)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func loadAll(perPage: Int? = nil, maxNumPages: Int? = nil, completion: (@Sendable () -> Void)? = nil) {
        loadSettings {
            DispatchQueue.main.async {
                self.loadCategories {
                    DispatchQueue.main.async {
                        self.loadPosts(perPage: perPage, maxNumPages: maxNumPages) {
                            DispatchQueue.main.async {
                                self.loadPages(perPage: perPage, maxNumPages: maxNumPages) {
                                    completion?()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func loadSettings(completion: (@Sendable () -> Void)? = nil) {
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
    func loadPost(id: Int, completion: (@Sendable () -> Void)? = nil) {
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
    func loadPosts(perPage: Int? = nil, maxNumPages: Int? = nil, completion: (@Sendable () -> Void)? = nil) {
        site.fetchContent(WordpressPost.self, perPage: perPage, maxNumPages: maxNumPages) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let posts):
                    posts.forEach { self.posts.update(with: $0) }
                case .failure(let error):
                    print("Error loadPosts")
                    self.processError(error)
                }
            }
        } completion: {
            completion?()
        }
    }
    
    // Loads pages with batching
    func loadPages(perPage: Int? = nil, maxNumPages: Int? = nil, completion: (@Sendable () -> Void)? = nil) {
        site.fetchContent(WordpressPage.self, perPage: perPage, maxNumPages: maxNumPages) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let pages):
                    pages.forEach { self.pages.update(with: $0) }
                case .failure(let error):
                    print("Error loadPosts")
                    self.processError(error)
                }
            }
        } completion: {
            completion?()
        }
    }
    
    // Loads all categories using batching
    func loadCategories(completion: (@Sendable () -> Void)? = nil) {
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
        self.error = errorString(error)
        print(error)
    }
    
    func errorString(_ error: Error) -> String {
        switch error {
        case WordpressReaderError.URLError.badURL:
            return "Bad URL"
        case WordpressReaderError.Network.requestFailed:
            return "Network problems: \(error.localizedDescription)"
        case WordpressReaderError.Network.unknown(let description):
            return "Unknown network error: \(description)"
        case is DecodingError:
            return "Decoding error: \(error.localizedDescription)"
        case is WordpressReaderError:
            return "WordpressReader error: \(error.localizedDescription)"
        default:
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}
