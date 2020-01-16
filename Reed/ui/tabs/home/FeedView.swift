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
    
    var body: some View {
        NavigationView {
            VStack {
                //1- country picker
                HStack() {
                    
                    Picker(selection: $feedViewModel.currentCountry, label: EmptyView()) {
                        ForEach(0..<self.feedViewModel.countries.count) { index in
                            Text(self.feedViewModel.country(for: index))
                                .tag(index)
                            
                        }
                    }.pickerStyle(SegmentedPickerStyle())
                        .fixedSize(horizontal: true, vertical: false)
                        .padding(.leading, 20)
                    
                    Spacer()
                }
                
                
                Spacer()
                
                //2- loading message
                if self.feedViewModel.isStatusMessageShown {
                    Text(self.feedViewModel.statusMessage)
                        .font(.footnote)
                }
                
                Spacer()
                
                //3- category picker
                Picker(selection: $feedViewModel.currentCategory, label: Text("Category")) {
                    ForEach(0..<self.feedViewModel.categories.count) { index in
                        Text(self.feedViewModel.categories[index]).tag(index)
                    }
                }.pickerStyle(SegmentedPickerStyle())
                
                Spacer(minLength: 20)
                GeometryReader { geometry in
                    RefreshableScrollView(refreshing: self.$feedViewModel.isLoading) {
                        //4- list filtered by category and country
                
                        
                            
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
                                
                                FeedCell(articleViewModel: self.feedViewModel.articleViewModel(at: idx, article: article))
                                    
                                    //1- when the cell/navigation link is visible...
                                    .onAppear(perform: {
                                        
                                        self.feedViewModel.filteredCount = count
                                        
                                        //2-...load more items if end of list is reached
                                        if idx == count - 1 {
                                            print("Info: Loading more headlines")
                                            self.feedViewModel.loadMoreArticlesWithCategoryAndCountry()
                                        }
                                        
                                        self.feedViewModel.loadImage(for: article, at: idx)
                                    })
                            }
                        }
                        .alert(isPresented: self.$feedViewModel.isErrorShown, content: { () -> Alert in
                            //if there's a fetching error, bubble it up
                            Alert(title: Text("Error"), message: Text(self.feedViewModel.errorMessage))
                        })
                            .padding(-20)
                            .frame(height: geometry.size.height - 20, alignment: .top)
                        
                    }
                }
            }
            .navigationBarTitle(Text("Top Headlines"))
            .navigationBarItems(
                trailing:
                
                HStack {
                    Button(action: {
                        self.feedViewModel.loadArticlesWithCategoryAndCountry()
                    }, label: {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.green)
                    })
                    
                    Spacer(minLength: 30)
                    
                    Button(action: {
                        self.feedViewModel.deleteAllArticles()
                    }, label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    })
                }
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

