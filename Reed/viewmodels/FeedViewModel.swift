//
//  FeedViewModel.swift
//  Reed
//
//  Created by Raven Weitzel on 12/16/19.
//  Copyright © 2019 Raven Weitzel. All rights reserved.
//

import Foundation

class FeedViewModel: ReedViewModel {
    
    //view model for each article
    private var articleViewModels = [Int: ArticleViewModel]()
    
    ///determines if an empty state message will be shown at all
    @Published var totalFeedLength: Int = 0
    
    ///should the "reached the end" message be shown
    @Published var showEnd: Bool = false {
        willSet {
            self.objectWillChange.send()
        }
    }
    
    //size of each page loaded when scrolling
    var feedPageSize: Int = 20
    
    //current page user is on
    var feedPage: Int = 1
    
    ///what the FilteredList binds to for data display
    override var isLoading: Bool {
        didSet {
            if oldValue == false && isLoading && !isRefreshingFeed {
                loadArticlesWithCategoryAndCountry()
            } else if isRefreshingFeed {
                isRefreshingFeed = false
                isLoading = false
            }
        }
    }
    
    ///toggles between a loading message and an empty state message
    var showLoadingMessage: Bool = true
    
    //don't hit API if feed is just being refreshed,
    //like from a cache clearing
    var isRefreshingFeed: Bool = false
    
    //MARK: - Filtering
    
    @Published var predicate: NSPredicate? {
        willSet {
            self.showLoadingMessage = true
        }
    }
    @Published var feedNavigationTitle: String = "Top Posts in America"
    
    //MARK: By Category
    
    var categoryFilterKey = "category"
    
    var categoryFilterValue: String {
        return categories[currentCategory]
    }
    
    var categoryIconDict = ["all": "🌍",
                            "business": "💼",
                            "entertainment": "🍿",
                            "science": "🧬",
                            "sports": "🏀"]
    
    var currentCategoryIcon: String {
        return categoryIconDict[categoryFilterValue]!
    }
    
    @Published var currentCategory = 0 {
        didSet {
            self.resetFilter()
            self.loadArticlesWithCategoryAndCountry()
        }
    }
    
    var categories: [String] {
        return Array(categoryIconDict.keys).sorted()
    }
    
    ///toggles the category ActionSheet
    @Published var showCategoryOptions: Bool = false {
        willSet {
            self.objectWillChange.send()
        }
    }
    
    //MARK: By Country
    
    var countryFilterKey = "country"
    
    var countryFilterValue: String {
        return countries[currentCountry]
    }
    
    var countryFlagDict = [ "us": "🇺🇸" ,
                            "gb": "🇬🇧",
                            "cn":"🇨🇳",
                            "ca": "🇨🇦"]
    
    var countries: [String] {
        return Array(countryFlagDict.keys).sorted()
    }
    
    var currentCountryFlag: String {
        return countryFlagDict[countryFilterValue]!
    }
    
    @Published var currentCountry = 0 {
        didSet {
            self.resetFilter()
            self.loadArticlesWithCategoryAndCountry()
        }
    }
    
    @Published var showCountryOptions: Bool = false {
        willSet {
            self.objectWillChange.send()
        }
    }
    
    override init() {
        super.init()
        
        loadArticlesWithCategoryAndCountry()
    }
    
    //MARK: Preview
    static func sample() {
        _ = ArticleViewModel.sample()
        _ = ArticleViewModel.longSample()
    }
}

//MARK: - Top Headlines
extension FeedViewModel {
    
    private func categoryForRequest() -> String {
        if categoryFilterValue == "all" {
            return "general"
        }
        
        return categoryFilterValue
    }
    
    
    private func loadTopHeadlinesWithSources(_ sources: [String],
                                             query: String? = nil) {
        
        let sources = [TopHeadlineRequiredParameters.sources(sources)]
        
        performTopHeadlinesRequest(requiredParams: sources, query: query)
    }
    
    private func loadTopHeadlines(from country: String? = nil,
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

//MARK: - NewsWebService Requests
extension FeedViewModel {
    
    /*
     Performs any request that returns a TopHeadlinesResponseObject, saving the articles to Core Data
     
     Note: page = 1 is the equivalent of adding no page parameter at all
     */
    private func performTopHeadlinesRequest(requiredParams: [TopHeadlineRequiredParameters],
                                            query: String? = nil) {
        
        //perform UI changes on the main thread
        DispatchQueue.main.async {
            self.showLoadingMessage = true
        }
        
        let topHeadlines = NewsWebService.topHeadlines(query: query,
                                                       page: self.feedPage,
                                                       pageSize: self.feedPageSize,
                                                       requiredParameters: requiredParams)
            .sink(receiveCompletion: { completion in
                
                self.isLoading = false
                self.showLoadingMessage = false
                
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
                CoreDataStack.shared.silentSafeSync(items: response.articles)
                self.totalFeedLength = response.totalResults
            })
        
        topHeadlines.cancel(with: self.cancelBag)
    }
}

//MARK: - Filter Management
extension FeedViewModel {
    
    private func setPredicate() {
        
        //"all" is not a category (but "general" is!)
        if categoryFilterValue != "all" {
            predicate = NSPredicate(format: "%K BEGINSWITH %@ AND %K BEGINSWITH %@",
                                    categoryFilterKey,
                                    categoryFilterValue,
                                    countryFilterKey,
                                    countryFilterValue)
        } else {
            //we still want to filter by country even though we aren't filtering by category
            predicate = NSPredicate(format: "%K BEGINSWITH %@" ,
                                    countryFilterKey,
                                    countryFilterValue)
        }
    }
    
    func resetFilter() {
        
        //remove all view models for the cells
        articleViewModels.removeAll()
        
        //reset total number of posts
        totalFeedLength = 0
        
        //reset the feed page
        feedPage = 1
    }
    
    //MARK: Category ActionSheet
    
    func categoryIdx(from category: String) -> Int {
        return categories.firstIndex(of: category)!
    }
    
    func setCategory(_ category: String) {
        let newCategory = categoryIdx(from: category)
        currentCategory = newCategory
    }
    
    //MARK: Country ActionSheet
    
    func countryIdx(from country: String) -> Int {
        return countries.firstIndex(of: country)!
    }
    
    func setCountry(_ country: String) {
        let newCountry = countryIdx(from: country)
        currentCountry = newCountry
    }
    
    //MARK: Display
    
    func filterPrettyPrinted() -> String? {
        
        if let country = countryName(for: countryFilterValue) {
            if categoryForRequest() != "general" {
                return  "\(country) \(categoryForRequest().capitalized)"
            }
            return country
        }
        
        return nil
    }
    
    func countryNamePrettyPrinted(iso: String) -> String {
        var pretty: String
        
        if let flag = countryFlagDict[iso] {
            pretty = flag
            
            if let countryName = countryName(for: iso) {
                pretty += " \(countryName) "
            }
        } else {
            pretty = iso
        }
        
        return pretty
    }
    
    func categoryNamePrettyPrinted(name: String) -> String {
        var pretty: String
        
        if let icon = categoryIconDict[name] {
            pretty = "\(icon) \(name.capitalized)"
        } else {
            pretty = name
        }
        
        return pretty
    }
    
    private func countryName(for iso: String) -> String? {
        let current = Locale(identifier: "en_US")
        return current.localizedString(forRegionCode: iso)
    }
}

//MARK: - Feed Management
extension FeedViewModel {
    
    func loadArticlesWithCategoryAndCountry() {
        
        setPredicate()
        let modifiedCategory = categoryForRequest()
        loadTopHeadlines(from: countryFilterValue,
                         fromCategory: modifiedCategory)
    }
    
    func loadMoreArticlesWithCategoryAndCountry() {
        
        if canIncrementPage() {
            feedPage += 1
            loadArticlesWithCategoryAndCountry()
        }
    }
    
    func refreshFeed() {
        isRefreshingFeed = true
        resetFilter()
        isLoading = true
    }
    
    func canIncrementPage() -> Bool {
        let maxDisplayableArticleCount = feedPage * feedPageSize
        
        guard maxDisplayableArticleCount < totalFeedLength else {
            return false
        }
        
        return true
    }
}

//MARK: Feed Item Management
extension FeedViewModel {
    
    func createViewModel(for article: Article, index: Int) -> ArticleViewModel {
        let viewModel = ArticleViewModel(article: article, index: index)
        
        articleViewModels[index] = viewModel
        
        return viewModel
    }
    
    func articleViewModel(at index: Int, article: Article) -> ArticleViewModel {
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
}


