//
//  FeedImage.swift
//  Reed
//
//  Created by Raven Weitzel on 1/10/20.
//  Copyright © 2020 Raven Weitzel. All rights reserved.
//

import SwiftUI

struct ArticleImage: View {
    
    var imageData: Data?
    var urlToImage: URL?
    var opacity: Double = 1.0
    
    var body: some View {
        
        return ZStack {
            
            VStack {
                
                if imageData == nil {
                    
                    if urlToImage != nil {
                        
                        //note: if a url is not https, it will not be fetched
                        Text("Can't get picture at \(urlToImage!)")
                            .foregroundColor(Color.red)
                            .font(.footnote)
                    } else {
                        Text("No url to fetch picture provided.")
                            .foregroundColor(Color.blue)
                            .font(.footnote)
                    }
                } else if imageFromData() == nil {
                    Text("Unable to create image from data.")
                        .foregroundColor(Color.orange)
                        .font(.footnote)
                }
                Spacer()
            }
            
            if imageFromData() != nil {
                image()
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .opacity(self.opacity)
                    .clipped()
            } else {
                //fade out system image a bit
                image()
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .opacity(0.4)
                    .clipped()
            }
            
            
            
            Spacer()
        }
    }
}

#if DEBUG
struct FeedImage_Previews: PreviewProvider {
    static var previews: some View {
        ArticleImage()
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
    
    func imageFromData() -> Image? {
        var image: Image? = nil
        
        if let imageData = imageData, let created = UIImage(data: imageData) {
            image = Image(uiImage: created)
        }
        
        return image
    }
    
    func image() -> Image {
        let image: Image
        
        if let created = imageFromData() {
            image = created
        } else {
            image = Image(systemName: "photo")
        }
        
        return image
    }
}
