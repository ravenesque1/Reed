//
//  FeedImage.swift
//  Reed
//
//  Created by Raven Weitzel on 1/10/20.
//  Copyright © 2020 Raven Weitzel. All rights reserved.
//

import SwiftUI

struct ArticleImage: View {
    
    @ObservedObject var articleImageViewModel: ArticleImageViewModel
    
    var opacity: Double = 1.0
    
    init(articleImageViewModel: ArticleImageViewModel) {
        self.articleImageViewModel = articleImageViewModel
    }
    
    var body: some View {
        
        return ZStack {
            
            //float message to the top of view
            VStack {
                
                //1- image message if not loaded
                Group {
                    
                    if !articleImageViewModel.loadedImage {
                        Text("Loading image...")
                            .foregroundColor(Color.green)
                    } else {
                        if !articleImageViewModel.hasImageData() {
                            if articleImageViewModel.hasImageUrl() {
                                
                                if articleImageViewModel.isInsecure() {
                                    Text("URL is insecure and will not fetch:\n\n \(articleImageViewModel.urlToImage!)")
                                        .foregroundColor(Color.red)
                                        .bold()
                                } else {
                                    Text("Can't get picture at \(articleImageViewModel.urlToImage!)")
                                        .foregroundColor(Color.red)
                                }
                            } else {
                                Text("No url to fetch picture provided.")
                                    .foregroundColor(Color.blue)
                            }
                        } else if articleImageViewModel.image == nil {
                            Text("Unable to create image from data.")
                                .foregroundColor(Color.orange)
                        }
                    }
                }
                .font(.footnote)
                .padding(20)
                
                Spacer()
            }
            
            //2- actual image
            image()
                .resizable()
                .aspectRatio(contentMode: .fill)
                .opacity(articleImageViewModel.image == nil ? 0.4 : self.opacity)
                .clipped()
            
            Spacer()
        }
    }
}

#if DEBUG
struct FeedImage_Previews: PreviewProvider {
    static var previews: some View {
        
        ArticleImage(articleImageViewModel: ArticleImageViewModel.sample())
            .previewLayout(.fixed(width: 400, height: 150))
    }
}
#endif

extension ArticleImage {
    
    func imageOpacity(_ opacity: Double) -> Self {
        var copy = self
        copy.opacity = opacity
        return copy
    }
    
    func image() -> Image {
        let image: Image
        
        if let created = articleImageViewModel.image {
            image = Image(uiImage: created)
        } else {
            image = Image(systemName: "photo")
        }
        
        return image
    }
}
