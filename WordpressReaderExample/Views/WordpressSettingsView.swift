//
//  WordpressSettingsView.swift
//  Wordhord
//
//  Created by Ryan Lintott on 2020-07-23.
//

import SwiftUI
import WordpressReader

struct WordpressSettingsView: View {
    let settings: WordpressSettings?
    
    var body: some View {
        if let settings = settings {
            NavigationView {
                Form {
                    URLImageView(url: settings.logo.url)
                        .padding()
                    
                    Section(header: Text("Description")) {
                        Text(settings.description)
                    }
                    
                    Section(header: Text("URL")) {
                        Text(settings.URL)
                    }
                }
                .navigationBarTitle(settings.name)
            }
        }
    }
}

struct WordpressSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        WordpressSettingsView(settings: .example)
    }
}
