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
    var opacity: Double = 1.0
    
    var body: some View {
        
        let image: Image
        
        if imageData != nil {
            image = Image(uiImage: UIImage(data: imageData!)!)
        } else {
            image = Image(systemName: "photo")
            
        }
        
        return image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .opacity(self.opacity)
            .clipped()
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
}
