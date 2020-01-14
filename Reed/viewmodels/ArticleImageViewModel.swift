//
//  ArticleImageViewModel.swift
//  Reed
//
//  Created by Raven Weitzel on 1/13/20.
//  Copyright © 2020 Raven Weitzel. All rights reserved.
//

import UIKit

class ArticleImageViewModel: ReedViewModel {
    
    @Published var article: Article
    @Published var loadedImage: Bool = false

    var index: Int
    
    var image: UIImage? {
        return imageFromData()
    }

    var imageData: Data? {
        return article.imageData
    }
    
    var urlToImage: URL? {
        return article.urlToImage
    }
    
    init(article: Article, index: Int) {
        self.article = article
        self.index = index
        super.init()
    }
    
    //MARK: Preview
    static func sample() -> ArticleImageViewModel {
        let article = Article(context: CoreDataStack.shared.persistentContainer.viewContext)
        article.title = "A shorty short title"
        article.summary = "A quick summary"
        article.author = "Some girl"
        article.publishedAt = Date()

        return ArticleImageViewModel(article: article, index: 0)
    }
}

extension ArticleImageViewModel {
    
    func hasImageData() -> Bool {
        return imageData != nil
    }
    
    func hasImageUrl() -> Bool {
        return urlToImage != nil
    }
    
    func imageFromData() -> UIImage? {
        
        if let imageData = article.imageData, let created = UIImage(data: imageData) {
            return created
        }
        return nil
    }

    //asynchronously loads an article's image
    func loadImage() {
        
        guard let imageUrl = article.urlToImage, article.imageData == nil else {
            
            if article.imageData != nil {
                self.objectWillChange.send()
                self.loadedImage = true
            }
            
            if article.urlToImage == nil {
                print("Warning! No image url for \(self.index)")
            }
            return
        }
        
        let loadImage = NewsWebService.loadImage(url: imageUrl)
                   .sink(receiveCompletion: { completion in
                    
                    self.objectWillChange.send()
                    self.loadedImage = true
                    
                       switch completion {
                       case .finished:
                           self.isErrorShown = false
                           break
                       case .failure(let error):
                           self.errorMessage = error.localizedDescription
                           self.isErrorShown = true
                           print("Error: Failed to download image for \(self.index): \(self.errorMessage)")
                       }
                   }, receiveValue: { response in
                        CoreDataStack.shared.saveImageData(response, to: self.article.objectID)
                   })
               
               loadImage.cancel(with: self.cancelBag)
    }
}
