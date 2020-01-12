//
//  FeedCellView.swift
//  Reed
//
//  Created by Raven Weitzel on 12/18/19.
//  Copyright © 2019 Raven Weitzel. All rights reserved.
//

import SwiftUI

struct FeedCellView: View {
    
    var articleViewModel: ArticleViewModel
    
    var body: some View {
        
        return ZStack {
            
            FeedImage(imageData: articleViewModel.article.imageData)
            
            
            HStack {
                VStack(alignment: .leading) {
                    
                    Spacer()
                    
                    Text(articleViewModel.article.title)
                        .font(.headline)
                    
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
    }
}

#if DEBUG
struct FeedCellView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FeedCellView(articleViewModel: ArticleViewModel.sample())
            FeedCellView(articleViewModel: ArticleViewModel.longSample())
        }
        .previewLayout(.fixed(width: 400, height: 300))
        .environment(\.managedObjectContext, CoreDataStack.shared.persistentContainer.viewContext)
    }
}
#endif

