//
//  FeedView.swift
//  Reed
//
//  Created by Raven Weitzel on 11/8/19.
//  Copyright © 2019 Raven Weitzel. All rights reserved.
//

import SwiftUI
import Combine

struct FeedView: View {
    
    private var feedViewModel = FeedViewModel()
    
    @FetchRequest(
        entity: Article.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Article.publishedAt, ascending: true),
        ]
    ) var articles: FetchedResults<Article>
    
    var body: some View {
        ReedHiddenNavBarView {
            VStack {
                Spacer()
                Text("Feed: \(articles.count) Articles")
                
                Spacer()
                
                ReedButton(
                    color: .red,
                    title: "Delete all articles",
                    action: {
                        self.feedViewModel.deleteAllArticles()
                })
                
                Spacer()
                
                ReedButton(
                    color: .green,
                    title: "Load top headlines",
                    action: {
                        self.feedViewModel.loadTopHeadlines()
                })
                
                Spacer()
                
                List(articles) { article in
                    FeedCellView(article: article)
                }
            }
        }
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView()
    }
}
