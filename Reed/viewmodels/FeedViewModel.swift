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
    
    //listening for changes to Article entities in Core Data
    @FetchRequest(
        entity: Article.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Article.publishedAt, ascending: true),
        ]
    ) var articles: FetchedResults<Article>
    
    
    override init() {
        super.init()
        
        loadTopHeadlinesFromAmerica()
    }
}

//MARK: - Top Headlines
extension FeedViewModel {
    
    func loadTopHeadlinesFromAmerica() {
        loadTopHeadlines()
    }
    
    func loadTopHeadlinesWithSources(_ sources: [String],
                                     query: String? = nil,
                                     page: Int? = nil,
                                     pageSize: Int? = nil) {
        
        let sources = [TopHeadlineRequiredParameters.sources(sources)]
        
        performTopHeadlinesRequest(requiredParams: sources, query: query, page: page, pageSize: pageSize)
    }
    
    func loadTopHeadlines(from country: String? = "us",
                          fromCategory: String? = nil,
                          query: String? = nil,
                          page: Int? = nil,
                          pageSize: Int? = nil) {
        
        var requiredParams: [TopHeadlineRequiredParameters] = []
        
        if let country = country {
            requiredParams += [TopHeadlineRequiredParameters.country(country)]
        }
        
        if let category = fromCategory {
            requiredParams += [TopHeadlineRequiredParameters.category(category)]
        }
        
        performTopHeadlinesRequest(requiredParams: requiredParams, query: query, page: page, pageSize: pageSize)
    }
}

//MARK: - Fetching
extension FeedViewModel {
    
    ///performs any request that returns a TopHeadlinesResponseObject, saving the articles to Core Data
    private func performTopHeadlinesRequest(requiredParams: [TopHeadlineRequiredParameters],
                                            query: String? = nil,
                                            page: Int? = nil,
                                            pageSize: Int? = nil) {
        
        let topHeadlines = NewsWebService.topHeadlines(query: query,
                                                       page: page,
                                                       pageSize: pageSize,
                                                       requiredParameters: requiredParams)
            .sink(receiveCompletion: { self.loadArticlesFailure(error: $0) },
                  receiveValue: { CoreDataStack.shared.silentSync(items: $0.articles) })
        
        topHeadlines.cancel(with: self.cancelBag)
    }
    
    private func loadArticlesFailure(error: Subscribers.Completion<Error>) {
        print(error)
    }
}

//MARK: - Deletion

extension FeedViewModel {
    
    func deleteAllArticles() {
        CoreDataStack.shared.deleteAllManagedObjectsOfEntityName("Article")
    }
}
