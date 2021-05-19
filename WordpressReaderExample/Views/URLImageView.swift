//
//  URLImageView.swift
//  WordpressReaderExample
//
//  Created by Ryan Lintott on 2021-05-18.
//

import SwiftUI

struct URLImageView: View {
    let url: String
    
    @State private var image: Image? = nil
    
    var body: some View {
        ZStack {
            image?
                .resizable()
                .scaledToFit()
        }
        .onAppear(perform: loadImage)
    }
    
    func loadImage() {
        guard let url = URL(string: url) else {
            print("URLImageView: Bad url")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                print("URLSession Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            if let uiImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    image = Image(uiImage: uiImage)
                }
            }
        }.resume()
    }
}

struct URLImageView_Previews: PreviewProvider {
    static var previews: some View {
        URLImageView(url: "https://oldenglishwordhord.files.wordpress.com/2019/04/wordwyrm-05-no-text.png")
    }
}
