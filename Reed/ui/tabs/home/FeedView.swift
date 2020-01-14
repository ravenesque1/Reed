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
    //
    //    @FetchRequest(
    //        entity: Article.entity(),
    //        sortDescriptors: [
    //            NSSortDescriptor(keyPath: \Article.publishedAt, ascending: true),
    //        ]
    //    ) var articles: FetchedResults<Article>
    
    var body: some View {
        NavigationView {

            VStack {

                if self.feedViewModel.isStatusMessageShown {
                    Text(self.feedViewModel.statusMessage)
                        .font(.footnote)
                }

                if self.feedViewModel.predicate != nil {
                    Text("predicate: \(self.feedViewModel.predicate!)")
                }

                Text("\(self.feedViewModel.filteredCount) total.")
                

                Spacer()

                //                ReedButton(
                //                    color: .green,
                //                    title: "Load top headlines",
                //                    action: {
                //                        self.feedViewModel.loadTopHeadlines()
                //                })
                
                //                ReedButton(
                //                    color: .red,
                //                    title: "filter test",
                //                    action: {
                //                        self.feedViewModel.togglePredicate()
                //                })

                Picker(selection: $feedViewModel.currentCategory, label: Text("Category")) {
                    ForEach(0..<self.feedViewModel.categories.count) { index in
                        Text(self.feedViewModel.categories[index]).tag(index)
                    }
                }.pickerStyle(SegmentedPickerStyle())

                Spacer(minLength: 20)
                
                FilteredList(predicate: self.feedViewModel.predicate) { (idx, article: Article, count) in

                    VStack {
                        //navigation link
                        NavigationLink(destination: ArticleView(articleViewModel: self.feedViewModel.articleViewModel(at: idx, article: article))) {

                            //ordinarily, the "tap here!" struct would go here, but the
                            //NavigationLink comes with a (here unwanted) disclosure indicator
                            //arrow. Using an EmptyView here, and stacking my "tap here!" struct
                            //in a VStack (or ZStack honestly) acheives the desired effect.
                            EmptyView()
                        }

                        //feed cell goes nuts..
                        FeedCell(articleViewModel: self.feedViewModel.articleViewModel(at: idx, article: article))
//                        Text(article.title)
                            //1- when the cell/navigation link is visible...
                            .onAppear(perform: {

                                //                                let count = self.feedViewModel.filteredCount

                                self.feedViewModel.filteredCount = count
                                print(">>>✨WELCOME at index \(idx)! article with title \n\n\(article.title)")

                                //2-...load more items if end of list is reached
                                if idx == count - 1 {
                                    print("Info: Loading more headlines")
                                    self.feedViewModel.loadMoreAmericanTopHeadlinesWithCategory()
                                }
                                
                                self.feedViewModel.loadImage(for: article, at: idx)
                            })
                    }


                    //                    VStack {
                    //                        //navigation link
                    //                        NavigationLink(destination: ArticleView(articleViewModel: self.feedViewModel.articleViewModel(at: idx, article: article))) {
                    //
                    //                            //ordinarily, the "tap here!" struct would go here, but the
                    //                            //NavigationLink comes with a (here unwanted) disclosure indicator
                    //                            //arrow. Using an EmptyView here, and stacking my "tap here!" struct
                    //                            //in a VStack (or ZStack honestly) acheives the desired effect.
                    //                            EmptyView()
                    //                        }
                    //
                    //                        //cell that will link to detail when tapped
                    //                        FeedCell(articleViewModel: self.feedViewModel.articleViewModel(at: idx, article: article))
                    //
                    //                            //1- when the cell/navigation link is visible...
                    //                            .onAppear(perform: {
                    //
                    ////                                let count = self.feedViewModel.filteredCount
                    //
                    //                                //2-...load more items if end of list is reached
                    //                                if idx == count - 1 {
                    //                                    print("Info: Loading more headlines")
                    //                                    self.feedViewModel.loadMoreAmericanTopHeadlinesWithCategory()
                    //                                }
                    //                                if let imageUrl = article.urlToImage {
                    //                                    let cellViewModel = self.feedViewModel.articleViewModel(at: idx, article: article).articleImageViewModel
                    //                                    cellViewModel.loadImage(url: imageUrl, idx: idx)
                    //                                }
                    //                            })
                    //                    }
                }

                    //grab the index as well as the article for inifinite scrolling
                    //                List (articles.enumerated().map { $0 }, id: \.1.id) { (idx, article) in
                    //
                    //
                    //                }
                    .alert(isPresented: self.$feedViewModel.isErrorShown, content: { () -> Alert in
                        //if there's a fetching error, bubble it up
                        Alert(title: Text("Error"), message: Text(feedViewModel.errorMessage))
                    })
                    .padding(-20)
            }
            .navigationBarTitle(Text("Top Headlines"))
            .navigationBarItems(
                leading: Button(action: {
                    self.feedViewModel.loadAmericanTopHeadlinesWithCategory()
                }, label: {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.green)
                }),
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

