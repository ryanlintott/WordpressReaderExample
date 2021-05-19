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
    
    func loadAll(perPage: Int? = nil, maxNumPages: Int? = nil, completion: (() -> Void)? = nil) {
        loadSettings {
            self.loadPosts(perPage: perPage, maxNumPages: maxNumPages) {
                self.loadPages(perPage: perPage, maxNumPages: maxNumPages) {
                    self.loadCategories {
                        completion?()
                    }
                }
            }
        }
    }
    
    func loadSettings(completion: (() -> Void)? = nil) {
        site.fetchSettings { result in
            switch result {
            case .success(let settings):
                DispatchQueue.main.async {
                    self.settings = settings
                }
            case .failure(let error):
                print("Error loadSettings")
                self.processError(error)
            }
            completion?()
        }
    }
    
    // Loads a single post by id
    func loadPost(id: Int, completion: (() -> Void)? = nil) {
        site.fetchById(WordpressPost.self, id: id) { result in
            switch result {
            case .success(let post):
                DispatchQueue.main.async {
                    self.singlePost = post
                }
            case .failure(let error):
                print("Error loadPost")
                self.processError(error)
            }
            completion?()
        }
    }
    
    // Loads up to 100 posts without batching
    func loadPosts(perPage: Int? = nil, maxNumPages: Int? = nil, completion: (() -> Void)? = nil) {
        site.fetchContent(WordpressPost.self, perPage: perPage, maxNumPages: maxNumPages) { result in
            switch result {
            case .success(let posts):
                DispatchQueue.main.async {
                    self.posts = posts
                }
            case .failure(let error):
                print("Error loadPosts")
                self.processError(error)
            }
            completion?()
        }
    }
    
    // Loads up to 100 pages without batching
    func loadPages(perPage: Int? = nil, maxNumPages: Int? = nil, completion: (() -> Void)? = nil) {
        site.fetchContent(WordpressPage.self, perPage: perPage, maxNumPages: maxNumPages) { result in
            switch result {
            case .success(let pages):
                DispatchQueue.main.async {
                    self.pages = pages
                }
            case .failure(let error):
                print("Error loadPosts")
                self.processError(error)
            }
            completion?()
        }
    }
    
    // Loads all categories using batching
    func loadCategories(completion: (() -> Void)? = nil) {
        site.fetchAllItems(WordpressCategory.self) { result in
            switch result {
            case .success(let categories):
                DispatchQueue.main.async {
                    self.categories = categories
                }
            case .failure(let error):
                print("Error loadCategories")
                self.processError(error)
            }
            completion?()
        }
    }
    
    func processError(_ error: Error) {
        switch error {
        case NetworkError.badURL:
            print("Bad URL")
        case NetworkError.requestFailed:
            print("Network problems: \(error.localizedDescription)")
        case NetworkError.unknown:
            print("Unknown network error: \(error.localizedDescription)")
        case is DecodingError:
            print("Decoding error: \(error.localizedDescription)")
        default:
            print("Unknown error: \(error.localizedDescription)")
        }
    }
}
