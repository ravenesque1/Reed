//
//  ArticleViewModel.swift
//  Reed
//
//  Created by Raven Weitzel on 1/10/20.
//  Copyright © 2020 Raven Weitzel. All rights reserved.
//

import Foundation

class ArticleViewModel: ReedViewModel {
    
    var article: Article
    var loadedImage: Bool = false
    
    init(article: Article) {
        self.article = article
        super.init()
    }
    
    //MARK: Preview
    static func sample() -> ArticleViewModel {
        let article = Article(context: CoreDataStack.shared.persistentContainer.viewContext)
        article.title = "A shorty short title"
        article.summary = "A quick summary"
        article.author = "Some girl"
        
        return ArticleViewModel(article: article)
    }
    
    static func longSample() -> ArticleViewModel {
        let article = Article(context: CoreDataStack.shared.persistentContainer.viewContext)
        article.title = "An extra long and confusing totally wordy title. An extra long and confusing totally wordy title."
        article.summary = "A long long long long long long long long long long long long long long long long long long long long long long long long summary"
        article.author = "Some girl, but with a really long name"
        
        return ArticleViewModel(article: article)
    }
}

//MARK: Async Image Loading
extension ArticleViewModel {
    
    func loadImage(url: URL, idx: Int) {
        
        guard let imageUrl = article.urlToImage, article.imageData == nil else {    
            if article.urlToImage == nil {
                print("Warning! No image url for \(idx)")
            }
            return
        }
        
        let loadImage = NewsWebService.loadImage(url: imageUrl)
                   .sink(receiveCompletion: { completion in
                       switch completion {
                       case .finished:
                           self.isErrorShown = false
                           break
                       case .failure(let error):
                           self.errorMessage = error.localizedDescription
                           self.isErrorShown = true
                           print("Error: Failed to download image for \(idx): \(self.errorMessage)")
                       }
                   }, receiveValue: { response in
                        CoreDataStack.shared.saveImageData(response, to: self.article.objectID)
                   })
               
               loadImage.cancel(with: self.cancelBag)
    }
}
