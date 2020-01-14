//
//  FeedViewModel.swift
//  Reed
//
//  Created by Raven Weitzel on 12/16/19.
//  Copyright © 2019 Raven Weitzel. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

class FeedViewModel: ReedViewModel {
    
    //view model for each article
    //TODO: adding @Published here blows things up
    private var articleViewModels = [Int: ArticleViewModel]() {
        didSet {
            
            print(">>>contains \(self.articleViewModels.values.count) view models")
            
        }
    }
    
    
    //true result count for "infinite" scroll
    var totalFeedLength: Int = 0
    
    //size of each page loaded when scrolling
    var feedPageSize: Int = 20
    
    //current page user is on
    var feedPage: Int = 1
    
    //filtering categories
    var categoryFilterKey = "category"
    
    var categoryFilterValue: String {
        return categories[currentCategory]
    }

    @Published var currentCategory = 0 {
        didSet {
            self.resetFilter()
            self.loadAmericanTopHeadlinesWithCategory()
        }
    }

    var categories = ["all", "business", "entertainment", "science"]
    
    
    
    //filtering countries
    var countryFilterKey = "country"
    
    var countryFilterValue: String {
        return countries[currentCountry]
    }
    
    var countryFlagDict = [ "us": "🇺🇸" ,
                            "gb": "🇬🇧",
                            "cn":"🇨🇳"]
    
    var countries: [String] {
        return Array(countryFlagDict.keys)
    }
    @Published var currentCountry = 0 {
        didSet {
            self.resetFilter()
            self.loadAmericanTopHeadlinesWithCategory()
        }
    }
    

    @Published var predicate: NSPredicate?
    @Published var feedNavigationTitle: String = "Top Posts in America"
    @Published var filteredCount: Int = 0
    
    override init() {
        super.init()
        
//        loadTopHeadlinesFromAmerica()
        loadAmericanTopHeadlinesWithCategory()
    }
    
    //MARK: Preview
    static func sample() {
        _ = ArticleViewModel.sample()
        _ = ArticleViewModel.longSample()
    }
}

//MARK: - Top Headlines
extension FeedViewModel {
    
//    func loadGlobalTopHeadlines() {
//        feedNavigationTitle = "Top Posts Everywhere"
//
//        loadTopHeadlines(fromCategory: self.filterValue)
//    }
//
//    func loadMoreGlobalTopHeadlines() {
//        incrementPage()
//        loadGlobalTopHeadlines()
//    }
//
//    func loadTopHeadlinesFromAmerica() {
//        feedNavigationTitle = "Top Posts in America"
//        loadTopHeadlines(from: self.filterValue)
//    }
//
//    func loadMoreTopHeadlinesFromAmerica() {
//        incrementPage()
//        loadTopHeadlinesFromAmerica()
//    }
    

    func loadAmericanTopHeadlinesWithCategory() {



        //"all" is not a category (but "general" is!)
        let trueCurrent = self.categories[self.currentCategory]

        var category: String? = "general"

        if trueCurrent != "all" {
            predicate = NSPredicate(format: "%K BEGINSWITH %@ AND %K BEGINSWITH %@",
                                    categoryFilterKey,
                                    categoryFilterValue,
            countryFilterKey,
            countryFilterValue)
            category = trueCurrent
        } else {
            //we still want to filter by country even though we aren't filtering by category
            predicate = NSPredicate(format: "%K BEGINSWITH %@" ,
            countryFilterKey,
            countryFilterValue)
        }

        loadTopHeadlines(from: countryFilterValue,
                         fromCategory: category)

//        loadTopHeadlines(fromCategory: self.categories[currentCategory])
    }

    func loadMoreAmericanTopHeadlinesWithCategory() {
        incrementPage()
        loadAmericanTopHeadlinesWithCategory()
    }
    
    private func incrementPage() {
        let maxDisplayableArticleCount = feedPage * feedPageSize
        
        guard maxDisplayableArticleCount < totalFeedLength else {
            print("Info: Reached end of infinite scroll.")
            return
        }
        
        feedPage += 1
        
        
        print("Info: Scrolling to page \(feedPage)...")
    }
    
    
    func loadTopHeadlinesWithSources(_ sources: [String],
                                     query: String? = nil) {
        
        let sources = [TopHeadlineRequiredParameters.sources(sources)]
        
        performTopHeadlinesRequest(requiredParams: sources, query: query)
    }
    
    func loadTopHeadlines(from country: String? = nil,
                          fromCategory: String? = nil,
                          query: String? = nil) {
        
        var requiredParams: [TopHeadlineRequiredParameters] = []
        
        if let country = country {
            requiredParams += [TopHeadlineRequiredParameters.country(country)]
        }
        
        if let category = fromCategory {
            requiredParams += [TopHeadlineRequiredParameters.category(category)]
        }

        performTopHeadlinesRequest(requiredParams: requiredParams, query: query)
    }
}

//MARK: - Fetching
extension FeedViewModel {
    
    /*
     Performs any request that returns a TopHeadlinesResponseObject, saving the articles to Core Data
    
     Note: page = 1 is the equivalent of adding no page parameter at all
    */
    private func performTopHeadlinesRequest(requiredParams: [TopHeadlineRequiredParameters],
                                            query: String? = nil) {

        //perform UI changes on the main thread

        self.objectWillChange.send()

        DispatchQueue.main.async {
            self.statusMessage = "loading headlines..."
            self.isStatusMessageShown = true
            self.filteredCount = 0
            print(">>>loading headline... \(requiredParams)")
        }
        
        let topHeadlines = NewsWebService.topHeadlines(query: query,
                                                       page: self.feedPage,
                                                       pageSize: self.feedPageSize,
                                                       requiredParameters: requiredParams)
            .sink(receiveCompletion: { completion in

//                 self.objectWillChange.send()
                self.isStatusMessageShown = false
                switch completion {
                case .finished:
                    self.isErrorShown = false
                    break
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.isErrorShown = true
                }
            }, receiveValue: { response in
                
                response.articles.forEach{ maybeArticle in
                 
                    guard let article = maybeArticle.value else { return }
                    
                    for param in requiredParams {
                        switch param {
                        case .category(let category):
                            article.category = category
                        case .country(let country):
                            article.country = country
                        default:
                            //TODO: save source information
                            break
                        }
                    }
                    
                }

//                self.objectWillChange.send()
                print(">>>⚠️ SYNC BEING PERFORMED.")
                CoreDataStack.shared.silentSafeSync(items: response.articles)
                self.totalFeedLength = response.totalResults
            })
        
        topHeadlines.cancel(with: self.cancelBag)
    }
}

//MARK: - Deletion

extension FeedViewModel {
    
    func deleteAllArticles() {
        CoreDataStack.shared.deleteAllManagedObjectsOfEntityName("Article")
        
        resetFilter()
    }

    func resetFilter() {
        //remove all view models for the cells
        articleViewModels.removeAll()
        print(">>>⚠️ ALL VIEW MODELS DELETED")
        
        //reset total number of posts
        totalFeedLength = 0
        
        //reset the feed page
        feedPage = 1

        filteredCount = 0
    }
}

//MARK: - Article List (aka "Feed") Management
extension FeedViewModel {
    func createViewModel(for article: Article, index: Int) -> ArticleViewModel {
        let viewModel = ArticleViewModel(article: article, index: index)
        
        articleViewModels[index] = viewModel
        
        print("⛔️ made new view model since cached not found at index \(index).")
        return viewModel
    }
    
    func articleViewModel(at index: Int, article: Article) -> ArticleViewModel {
        
        print("/* looking for view model at index \(index) */")
        
        if let _ = articleViewModels[index] {
            print("✅ found cached view model at index \(index)!")
        }
        return articleViewModels[index] ?? createViewModel(for: article, index: index)
    }
    
    func loadImage(for article:Article, at index: Int) {
        
        //an array of references (classes instead of a struct) will
        //not emit a change, as the array itself did not change, thus
        //a manual trigger is necessary
        self.objectWillChange.send()
        
        let cellViewModel = articleViewModel(at: index, article: article).articleImageViewModel
        cellViewModel.loadImage()
    }
    
    func country(for idx: Int) -> String {
        return countryFlagDict[countries[idx]]!
    }
    
//    func togglePredicate() {
//        self.objectWillChange.send()
////        self.filterKey = filterKey == "country" ? "category" : "country"
//        self.filterValue = filterValue == "business" ? "general" : "business"
//        loadGlobalTopHeadlines()
//    }
}


