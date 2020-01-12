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
    
    @ObservedObject private var feedViewModel = FeedViewModel()
    
    @FetchRequest(
        entity: Article.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Article.publishedAt, ascending: true),
        ]
    ) var articles: FetchedResults<Article>
    
    var body: some View {
        ReedHiddenNavBarView {
            
            VStack {
                
                NavigationLink(destination: ArticleView(articleViewModel: self.feedViewModel.articleViewModel(at: 0) ?? ArticleViewModel.sample())) {
                    Text("am nav link")
                }
                
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
                
                //grab the index as well as the article for inifinite scrolling
                List (articles.enumerated().map { $0 }, id: \.1.id) { (idx, article) in
                    
                    //when the cell/navigation link is visible...
                    FeedCellView(articleViewModel: self.feedViewModel.createViewModel(for: article, index: idx))
                        .onAppear(perform: {
                            
                            let count = self.articles.count
                            
                            //...load more items if end of list is reached
                            if idx == count - 1 {
                                print("Info: Loading more headlines")
                                self.feedViewModel.loadMoreTopHeadlinesFromAmerica()
                            }
                            if let imageUrl = article.urlToImage,
                                let cellViewModel = self.feedViewModel.articleViewModel(at: idx) {
                                cellViewModel.loadImage(url: imageUrl, idx: idx)
                            }
                        })
                }
                .alert(isPresented: self.$feedViewModel.isErrorShown, content: { () -> Alert in
                    //if there's a fetching error, bubble it up
                    Alert(title: Text("Error"), message: Text(feedViewModel.errorMessage))
                })
                .padding(-20)
            }
        }
    }
}

#if DEBUG
struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        
        return FeedView()
            .environment(\.managedObjectContext, CoreDataStack.shared.persistentContainer.viewContext)
    }
}
#endif
