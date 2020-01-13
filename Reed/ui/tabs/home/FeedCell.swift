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
            
            ArticleImage(articleImageViewModel: articleViewModel.articleImageViewModel)
                .imageOpacity(0.4)
            
            
            HStack {
                VStack(alignment: .leading) {
                    
                    Spacer()
                    
                    Text(articleViewModel.article.source.name)
                    
                    Text(articleViewModel.article.title)
                        .font(.headline)
                    
//                    HStack {
//                        Text(articleViewModel.article.author)
//                            .fontWeight(.bold)
//                            .lineLimit(1)
                        
                        if articleViewModel.hasTimeAgoString {
                            Text(articleViewModel.timeAgoString!)
                                .italic()
                            .font(.caption)
                        }
//                    }
                    
                    
//                    if articleViewModel.article.summary != nil {
//                        Text(articleViewModel.article.summary!)
//                            .font(.body)
//                    }
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

