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
        
        //0- ZStack places article information in front of image
        return ZStack {
            
            //1- image
            ArticleImage(articleImageViewModel: articleViewModel.articleImageViewModel)
                .imageOpacity(0.4)
            
            //2- article information
            HStack {
                VStack(alignment: .leading) {
                    
                    Spacer()
                    
                    Text(articleViewModel.article.source.name)
                    
                    Text(articleViewModel.article.title)
                        .font(.headline)
                    
                    if articleViewModel.hasTimeAgoString {
                        Text(articleViewModel.timeAgoString!)
                            .italic()
                            .font(.caption)
                    }
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

