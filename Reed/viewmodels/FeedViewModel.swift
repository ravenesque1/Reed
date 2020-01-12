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
    private var articleViewModels = [Int: ArticleViewModel]()
    
    //true result count for "infinite" scroll
    var totalFeedLength: Int = 0
    
    //size of each page loaded when scrolling
    var feedPageSize: Int = 20
    
    //current page user is on
    var feedPage: Int = 1
    
    override init() {
        super.init()
        
        loadTopHeadlinesFromAmerica()
    }
    
    //MARK: Preview
    static func sample() {
        _ = ArticleViewModel.sample()
        _ = ArticleViewModel.longSample()
    }
}

//MARK: - Top Headlines
extension FeedViewModel {
    
    func loadTopHeadlinesFromAmerica() {
        loadTopHeadlines()
    }
    
    func loadMoreTopHeadlinesFromAmerica() {
        
        let maxDisplayableArticleCount = feedPage * feedPageSize
        
        guard maxDisplayableArticleCount < totalFeedLength else {
            print("Info: Reached end of infinite scroll.")
            return
        }
        
        feedPage += 1
        
        
        print("Info: Scrolling to page \(feedPage)...")
        
        loadTopHeadlines()
    }
    
    
    func loadTopHeadlinesWithSources(_ sources: [String],
                                     query: String? = nil) {
        
        let sources = [TopHeadlineRequiredParameters.sources(sources)]
        
        performTopHeadlinesRequest(requiredParams: sources, query: query)
    }
    
    func loadTopHeadlines(from country: String? = "us",
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
        
        let topHeadlines = NewsWebService.topHeadlines(query: query,
                                                       page: self.feedPage,
                                                       pageSize: self.feedPageSize,
                                                       requiredParameters: requiredParams)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    self.isErrorShown = false
                    break
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.isErrorShown = true
                }
            }, receiveValue: { response in
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
        
        //remove all view models for the cells
        articleViewModels.removeAll()
        
        //reset total number of posts
        totalFeedLength = 0
        
        //reset the feed page
        feedPage = 1
    }
}

//MARK: - Article List (aka "Feed") Management
extension FeedViewModel {
    func createViewModel(for article: Article, index: Int) -> ArticleViewModel {
        let viewModel = ArticleViewModel(article: article)
        
        articleViewModels[index] = viewModel
        
        return viewModel
    }
    
   func articleViewModel(at index: Int) -> ArticleViewModel? {
        return articleViewModels[index]
    }
}


