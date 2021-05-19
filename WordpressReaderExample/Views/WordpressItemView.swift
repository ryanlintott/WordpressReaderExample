//
//  WordpressItemView.swift
//  WordpressReaderExample
//
//  Created by Ryan Lintott on 2021-05-18.
//

import SwiftUI
import WordpressReader

struct WordpressItemView<T: WordpressItem>: View {
    let item: T
    
    init(_ item: T) {
        self.item = item
    }
    
    var title: String {
        if let item = item as? WordpressPost {
            return item.titleCleaned
        } else if let item = item as? WordpressPage {
            return item.titleCleaned
        } else {
            return item.slug
        }
    }
    
    var body: some View {
        Form {
            Section(header: Text("ID")) {
                Text("\(item.id)")
            }
            
            Section(header: Text("Link")) {
                Text(item.link)
            }
            
            if let content = item as? WordpressContent {
                Section(header: Text("Slug")) {
                    Text(content.slugCleaned)
                }
                
                Section(header: Text("Content")) {
                    Text(content.contentHtml)
                }
                
            }
            if let post = item as? WordpressPost {
                Section(header: Text("Categories")) {
                    ForEach(post.categories, id: \.self) { id in
                        Text(String(id))
                    }
                }
                
                Section(header: Text("Tags")) {
                    ForEach(post.tags, id: \.self) { id in
                        Text(String(id))
                    }
                }
            }
        }
        .navigationBarTitle(title)
    }
}

struct WordpressItemView_Previews: PreviewProvider {
    static var previews: some View {
        WordpressItemView(WordpressPost.example)
        
        WordpressItemView(WordpressPage.example)
        
        WordpressItemView(WordpressCategory.example)
    }
}
