//
//  ArticleViewModel.swift
//  Reed
//
//  Created by Raven Weitzel on 1/10/20.
//  Copyright © 2020 Raven Weitzel. All rights reserved.
//

import Foundation
import UIKit

class ArticleViewModel: ReedViewModel {
    
    @Published var articleImageViewModel: ArticleImageViewModel
    
    var timeAgoString: String? {
        return article.publishedAt.timeAgoString
    }
    
    var hasTimeAgoString: Bool {
        return timeAgoString != nil
    }
    
    @Published var article: Article
    @Published var showPreview = false
    @Published var previewButtonTitle: String = "Show Preview"
    @Published var viewButtonTitle: String = "View in Safari"
    
    init(article: Article, index: Int) {
        self.article = article
        self.articleImageViewModel = ArticleImageViewModel(article: article, index: index)
        super.init()
    }
    
    //MARK: Preview
    static func sample() -> ArticleViewModel {
        let article = Article(context: CoreDataStack.shared.persistentContainer.viewContext)
        article.title = "A shorty short title"
        article.summary = "A quick summary"
        article.author = "Some girl"
        article.publishedAt = Date()
        
        return ArticleViewModel(article: article, index: 0)
    }
    
    static func longSample() -> ArticleViewModel {
        let article = Article(context: CoreDataStack.shared.persistentContainer.viewContext)
        article.title = "An extra long and confusing totally wordy title. An extra long and confusing totally wordy title."
        article.summary = "A long long long long long long long long long long long long long long long long long long long long long long long long summary"
        article.author = "Some girl, but with a really long name"
        article.publishedAt = Date()
        
        return ArticleViewModel(article: article, index: 0)
    }
}

extension ArticleViewModel {
    
    func openInSafari() {
        UIApplication.shared.open(article.url)
    }
    
    //toggles the visibility of preview
    func toggleViewSource() {
        
        //when an ObservableObject is a class (rather than a struct),
        //it is pass by REFERENCE, not VALUE. As such, when a property
        //changes, the object doesn't emit a "change", thus the change
        //needs manual calling
        self.objectWillChange.send()
        self.showPreview = !self.showPreview
        self.previewButtonTitle = self.showPreview ? "Hide Preview" : "Show Preview"
        self.viewButtonTitle = self.showPreview ? "Continue in Safari" : "View in Safari"
    }
}
