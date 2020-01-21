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
    @EnvironmentObject var userAuth: UserSettings
    
    var body: some View {
        NavigationView {
            VStack {
                
                //1- provides filter information
                subheadline()
                    .font(.caption)
                    .align(.leading)
                    .padding(.leading, 20)
                
                //2- the GeometryReader is used to grab the size of the parent and do stuff
                GeometryReader { geometry in
                    
                    RefreshableScrollView(refreshing: self.$feedViewModel.isLoading) {
                        
                        if self.feedViewModel.totalFeedLength == 0 {
                            
                            //3- empty state message if there is nothing to display
                            Spacer()
                            VStack(spacing: 10) {
                                if self.feedViewModel.showLoadingMessage {
                                    Text("Loading articles...")
                                } else {
                                    Text("Sorry, no results.")
                                    Text("Pull to refresh or try a different country or category.")
                                        .font(.footnote)
                                        .foregroundColor(Color.gray)
                                }
                            }
                            .frame(minWidth: 0,
                                   maxWidth: .infinity,
                                   minHeight: 0,
                                   idealHeight: geometry.size.height - 20,
                                   maxHeight: .infinity)
                            Spacer()
                            
                        } else {
                            
                            //4- show results of API and filtering
                            FilteredList(predicate: self.feedViewModel.predicate) { (idx, article: Article, count) in
                                
                                VStack {
                                    
                                    //4a the article item itself vs....
                                    VStack(spacing: 0) {
                                        
                                        NavigationLink(destination: ArticleView(articleViewModel: self.feedViewModel.articleViewModel(at: idx, article: article))) {
                                            
                                            //ordinarily, the "tap here!" struct would go here, but the
                                            //NavigationLink comes with a (here unwanted) disclosure indicator
                                            //arrow. Using an EmptyView here, and stacking my "tap here!" struct
                                            //in a VStack (or ZStack honestly) acheives the desired effect.
                                            EmptyView()
                                        }
                                        
                                        FeedCell(articleViewModel: self.feedViewModel.articleViewModel(at: idx, article: article))
                                            
                                            //5a- when the cell/navigation link is visible...
                                            .onAppear(perform: {
                                                
                                                //5b-...load more items if end of list is reached
                                                if idx == count - 1 && !self.feedViewModel.isLoading {
                                                    self.feedViewModel.loadMoreArticlesWithCategoryAndCountry()
                                                } else {
                                                    self.feedViewModel.showEnd = true
                                                }
                                                
                                                self.feedViewModel.loadImage(for: article, at: idx)
                                            })
                                            
                                    }
                                    
                                    //4b- ...the end of view message
                                    if idx == count - 1 && self.feedViewModel.showEnd && !self.feedViewModel.canIncrementPage() {
                                        Spacer()
                                        
                                        Text("That's it! You've reached the end.")
                                        Text("🥳")
                                        
                                        Spacer()
                                    }
                                }
                            }
                                //if there's an error, bubble it up
                                .alert(isPresented: self.$feedViewModel.isErrorShown, content: self.feedViewErrorAlert)
                                .frame(height: geometry.size.height, alignment: .top)
                        }
                    }
                }
            }
            .onAppear(perform: {
                //5- the cache can be cleared elsewhere, so refresh the feed if that happens
                if self.userAuth.recentlyClearedCache {
                    self.feedViewModel.refreshFeed()
                    self.userAuth.recentlyClearedCache = false
                }
            })
                .navigationBarTitle(Text("Top Headlines"))
                .navigationBarItems(
                    trailing:
                    
                    HStack {
                        
                        //6- the country filtering navigation item
                        Button(action: {
                            self.feedViewModel.showCountryOptions = true
                        }, label: {
                            Text("\(self.feedViewModel.currentCountryFlag)")
                        })
                            .popSheet(isPresented: self.$feedViewModel.showCountryOptions, content: { self.countryActionSheet() })
                        
                        Spacer(minLength: 30)
                        
                        //7- the category filtering navigation iterm
                        Button(action: {
                            self.feedViewModel.showCategoryOptions = true
                        }, label: {
                            Text("\(self.feedViewModel.currentCategoryIcon)")
                        })
                            .popSheet(isPresented: self.$feedViewModel.showCategoryOptions, content: { self.categoryActionSheet() })
                    }
            )
            
            Text("<<< Swipe right from the left edge to expose the feed.")
            .padding()
        }
//        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#if DEBUG
struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        
        return FeedView()
            .environment(\.managedObjectContext, CoreDataStack.shared.persistentContainer.viewContext)
            .environmentObject(UserSettings())
    }
}
#endif

extension FeedView {
    
    func subheadline() -> Text? {
        if self.feedViewModel.filterPrettyPrinted() != nil {
            return Text(self.feedViewModel.filterPrettyPrinted()!)
        }
        return nil
    }
    
    func feedViewErrorAlert() -> Alert {
        return Alert(title: Text("Error"), message: Text(self.feedViewModel.errorMessage))
    }
    
    //MARK: Category Filtering UI
    
    func categoryActionSheet() -> PopSheet {
        return PopSheet(title: Text("Select category..."), buttons:
            self.feedViewModel.categories.map { actionSheetButton(withCategory: $0)} + [.destructive(Text("Cancel"))]
        )
    }
    
    func actionSheetButton(withCategory category: String) -> PopSheet.Button {
        return PopSheet.Button.default(Text(self.feedViewModel.categoryNamePrettyPrinted(name: category)), action: {
            self.feedViewModel.setCategory(category)
        })
    }
    
    //MARK: Country Filtering UI
    func countryActionSheet() -> PopSheet {
        return PopSheet(title: Text("Select country..."), buttons:
            self.feedViewModel.countries.map { actionSheetButton(withCountry: $0)} + [.destructive(Text("Cancel"))]
        )
    }
    
    func actionSheetButton(withCountry country: String) -> PopSheet.Button {
        return PopSheet.Button.default(Text(self.feedViewModel.countryNamePrettyPrinted(iso: country)), action: {
            self.feedViewModel.setCountry(country)
        })
    }
}
