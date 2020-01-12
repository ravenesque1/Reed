//
//  FeedImage.swift
//  Reed
//
//  Created by Raven Weitzel on 1/10/20.
//  Copyright © 2020 Raven Weitzel. All rights reserved.
//

import SwiftUI

struct FeedImage: View {
    
    var imageData: Data?
    
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
            .opacity(0.4)
            .clipped()
    }
}

#if DEBUG
struct FeedImage_Previews: PreviewProvider {
    static var previews: some View {
        FeedImage()
            .previewLayout(.fixed(width: 400, height: 150))
    }
}
#endif
