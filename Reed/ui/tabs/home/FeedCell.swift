//
//  FeedCellView.swift
//  Reed
//
//  Created by Raven Weitzel on 12/18/19.
//  Copyright © 2019 Raven Weitzel. All rights reserved.
//

import SwiftUI

struct FeedCell: View {
    
    @ObservedObject var articleViewModel: ArticleViewModel
    
    var body: some View {
        
        return ZStack {
            
            ArticleImage(imageData: articleViewModel.article.imageData, urlToImage: articleViewModel.article.urlToImage)
                .imageOpacity(0.4)
            
            
            HStack {
                VStack(alignment: .leading) {
                    
                    Spacer()
                    
                    Text(articleViewModel.article.title)
                        .font(.headline)
                    Text(articleViewModel.article.publishedAtPretty())
                        .font(.caption)
                    
                    if articleViewModel.article.summary != nil {
                        Text(articleViewModel.article.summary!)
                            .font(.body)
                    }
                    Text(articleViewModel.article.author)
                        .font(.subheadline)
                        .fontWeight(.bold)
                    
                }
                .padding(.leading, 10)
                .padding(.bottom, 10)
                
                Spacer()
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

#if DEBUG
struct FeedCellView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FeedCell(articleViewModel: ArticleViewModel.sample())
            FeedCell(articleViewModel: ArticleViewModel.longSample())
        }
        .previewLayout(.fixed(width: 400, height: 300))
        .environment(\.managedObjectContext, CoreDataStack.shared.persistentContainer.viewContext)
    }
}
#endif

