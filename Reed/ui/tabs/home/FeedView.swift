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
        NavigationView {

            VStack {

                Spacer()

                ReedButton(
                    color: .green,
                    title: "Load top headlines",
                    action: {
                        self.feedViewModel.loadTopHeadlines()
                })

                Spacer(minLength: 20)

                //grab the index as well as the article for inifinite scrolling
                List (articles.enumerated().map { $0 }, id: \.1.id) { (idx, article) in

                    VStack {
                        //navigation link
                        NavigationLink(destination: ArticleView(articleViewModel: self.feedViewModel.articleViewModel(at: idx, article: article))) {

                            //ordinarily, the "tap here!" struct would go here, but the
                            //NavigationLink comes with a (here unwanted) disclosure indicator
                            //arrow. Using an EmptyView here, and stacking my "tap here!" struct
                            //in a VStack (or ZStack honestly) acheives the desired effect.
                            EmptyView()
                        }

                        //cell that will link to detail when tapped
                        FeedCell(articleViewModel: self.feedViewModel.articleViewModel(at: idx, article: article))

                            //1- when the cell/navigation link is visible...
                            .onAppear(perform: {

                                let count = self.articles.count

                                //2-...load more items if end of list is reached
                                if idx == count - 1 {
                                    print("Info: Loading more headlines")
                                    self.feedViewModel.loadMoreTopHeadlinesFromAmerica()
                                }
                                if let imageUrl = article.urlToImage {
                                    let cellViewModel = self.feedViewModel.articleViewModel(at: idx, article: article).articleImageViewModel
                                    cellViewModel.loadImage(url: imageUrl, idx: idx)
                                }
                            })
                    }
                }
                .alert(isPresented: self.$feedViewModel.isErrorShown, content: { () -> Alert in
                    //if there's a fetching error, bubble it up
                    Alert(title: Text("Error"), message: Text(feedViewModel.errorMessage))
                })
                    .padding(-20)
            }
            .navigationBarTitle(Text("Feed: \(articles.count) Articles"))
            .navigationBarItems(
                trailing: Button(action: {
                self.feedViewModel.deleteAllArticles()
                }, label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                })
            )
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
