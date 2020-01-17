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
                
                //factor out
                if self.feedViewModel.filterPrettyPrinted() != nil {
                    Text(self.feedViewModel.filterPrettyPrinted()!)
                    .font(.caption)
                        .align(.leading)
                    .padding(.leading, 20)
                }
                
//                Text(self.feedViewModel.predicate?.description ?? "")
                //1- country picker
//                HStack() {
//
//                    Picker(selection: $feedViewModel.currentCountry, label: EmptyView()) {
//                        ForEach(0..<self.feedViewModel.countries.count) { index in
//                            Text(self.feedViewModel.country(for: index))
//                                .tag(index)
//
//                        }
//                    }.pickerStyle(SegmentedPickerStyle())
//                        .fixedSize(horizontal: true, vertical: false)
//                        .padding(.leading, 20)
//
//                    Spacer()
//                }
                
                
//                Spacer()
                
                //2- loading message
//                if self.feedViewModel.isStatusMessageShown {
//                    Text(self.feedViewModel.statusMessage)
//                        .font(.footnote)
//                }
                
//                Spacer()
                
                //3- category picker
//                Picker(selection: $feedViewModel.currentCategory, label: Text("Category")) {
//                    ForEach(0..<self.feedViewModel.categories.count) { index in
//                        Text(self.feedViewModel.categories[index]).tag(index)
//                    }
//                }.pickerStyle(SegmentedPickerStyle())
                
//                Spacer(minLength: 20)
                
                //4a- the GeometryReader is used to grab the size of the parent VStack...
                GeometryReader { geometry in
                    
                    RefreshableScrollView(refreshing: self.$feedViewModel.isLoading) {
                        //4- list filtered by category and country
                        
                        //note, not using filteredCount
                        if self.feedViewModel.totalFeedLength == 0 {
                            
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
                            }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, idealHeight: geometry.size.height - 20, maxHeight: .infinity)
                            
                            
                            Spacer()
                        } else {

                        FilteredList(predicate: self.feedViewModel.predicate) { (idx, article: Article, count) in
                            
                            VStack {
                            
                            VStack(spacing: 0) {
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
                                        
                                        if idx == count - 1 {
                                            print(">>>REFRESH")
                                        } else {
                                            print(">>>no refresh. at cell \(idx), need \(count - 1) and total feed length is \(self.feedViewModel.totalFeedLength)")
                                        }
                                        
                                        self.feedViewModel.filteredCount = count
                                        
                                        //2-...load more items if end of list is reached
                                        if idx == count - 1 && !self.feedViewModel.isLoading {
                                            print("Info: Loading more headlines")
                                            
                                            print(">>>total showing: \(count)")
                                            self.feedViewModel.loadMoreArticlesWithCategoryAndCountry()
                                        } else {
                                            self.feedViewModel.showEnd = true
                                        }
                                        
                                        self.feedViewModel.loadImage(for: article, at: idx)
                                    })
                                    
                            }
                                if idx == count - 1 && self.feedViewModel.showEnd && !self.feedViewModel.canIncrementPage() {
                                    Spacer()
                                        
                                    Text("That's it! You've reached the end.")
                                    Text("🥳")
                                        
                                    Spacer()
                                }
                                
                            }
                        }
                        .alert(isPresented: self.$feedViewModel.isErrorShown, content: { () -> Alert in
                            //if there's a fetching error, bubble it up
                            Alert(title: Text("Error"), message: Text(self.feedViewModel.errorMessage))
                        })
                            
                            //4b- and set the height of the list, because in this case
                            //the RefreshableScrollView prevents the FilteredList from
                            //filling the VStack as usual.
                            .frame(height: geometry.size.height, alignment: .top)
                        }
                    }
                    
                }
            }
        .onAppear(perform: {
            if self.userAuth.recentlyClearedCache {
                self.feedViewModel.refreshFeed()
                self.userAuth.recentlyClearedCache = false
            }
        })
            .navigationBarTitle(Text("Top Headlines"))
            .navigationBarItems(
                trailing:
                
                HStack {
                    Button(action: {
//                        self.feedViewModel.loadArticlesWithCategoryAndCountry()
                        self.feedViewModel.showCountryOptions = true
                    }, label: {
                        Text("\(self.feedViewModel.currentCountryFlag)")
                    })
                        .actionSheet(isPresented: self.$feedViewModel.showCountryOptions, content: { countryActionSheet() })
                    
                    Spacer(minLength: 30)
                    
                    Button(action: {
//                        self.feedViewModel.deleteAllArticles()
                        self.feedViewModel.showCategoryOptions = true
                    }, label: {
                        Text("\(self.feedViewModel.currentCategoryIcon)")
                    })
                    .actionSheet(isPresented: self.$feedViewModel.showCategoryOptions, content: { categoryActionSheet() })
                }
            )
//            .background(Color.green)
        }
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
    
    func categoryActionSheet() -> ActionSheet {
        return ActionSheet(title: Text("Select category..."), buttons:
            self.feedViewModel.categories.map { actionSheetButton(withCategory: $0)} + [.destructive(Text("Cancel"))]
        )
    }
    
    func actionSheetButton(withCategory category: String) -> ActionSheet.Button {
        return ActionSheet.Button.default(Text(self.feedViewModel.categoryNamePrettyPrinted(name: category)), action: {
            self.feedViewModel.setCategory(category)
        })
    }
    
    func countryActionSheet() -> ActionSheet {
        return ActionSheet(title: Text("Select country..."), buttons:
            self.feedViewModel.countries.map { actionSheetButton(withCountry: $0)} + [.destructive(Text("Cancel"))]
        )
    }
    
    func actionSheetButton(withCountry country: String) -> ActionSheet.Button {
        return ActionSheet.Button.default(Text(self.feedViewModel.countryNamePrettyPrinted(iso: country)), action: {
            self.feedViewModel.setCountry(country)
            })
    }
    
    func optionalText() -> Text? {
        return Text("")
    }
}
