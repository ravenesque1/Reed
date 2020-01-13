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
    
    var image: UIImage? {
        return imageFromData()
    }

    var imageData: Data? {
        return article.imageData
    }
    
    var urlToImage: URL? {
        return article.urlToImage
    }
    
    init(article: Article) {
        self.article = article
        super.init()
    }
    
    //MARK: Preview
    static func sample() -> ArticleImageViewModel {
        let article = Article(context: CoreDataStack.shared.persistentContainer.viewContext)
        article.title = "A shorty short title"
        article.summary = "A quick summary"
        article.author = "Some girl"
        article.publishedAt = Date()

        return ArticleImageViewModel(article: article)
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
    func loadImage(url: URL, idx: Int) {
        
        guard let imageUrl = article.urlToImage, article.imageData == nil else {
            
            if article.imageData != nil {
                self.objectWillChange.send()
                self.loadedImage = true
            }
            
            if article.urlToImage == nil {
                print("Warning! No image url for \(idx)")
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
                           print("Error: Failed to download image for \(idx): \(self.errorMessage)")
                       }
                   }, receiveValue: { response in
                        CoreDataStack.shared.saveImageData(response, to: self.article.objectID)
                   })
               
               loadImage.cancel(with: self.cancelBag)
    }
}
