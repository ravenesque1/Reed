//
//  Article.swift
//  Reed
//
//  Created by Raven Weitzel on 12/16/19.
//  Copyright © 2019 Raven Weitzel. All rights reserved.
//

import CoreData

class Article: NSManagedObject {
    
    enum CodingKeys: String, CodingKey {
        case source
        case author
        case title
        case summary  = "description"
        case url
        case urlToImage
        case publishedAt
        case content
    }
    
    @NSManaged var id: String
    @NSManaged var source: Source
    @NSManaged var author: String
    @NSManaged var title: String
    @NSManaged var summary: String?
    @NSManaged var url: URL
    @NSManaged var urlToImage: URL?
    @NSManaged var publishedAt: Date
    @NSManaged var content: String?
    @NSManaged var imageData: Data?
    
    
    static let intoDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        df.locale = Locale(identifier: "en_US_POSIX")
        return df
    }()
    
    static let fromDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "EEE MMM d, h:mm a"
        df.locale = Locale(identifier: "en_US_POSIX")
        return df
    }()
    
    static let decodeFailure = NSError(domain: "", code: 100, userInfo: ["Error": "Failed to decode Article"])
    
    //Mark: - Decodable (of Codable)
    required convenience init(from decoder: Decoder) throws {
        
        guard let codingUserInfoKeyManagedObjectContext = CodingUserInfoKey.managedObjectContext,
            let managedObjectContext = decoder.userInfo[codingUserInfoKeyManagedObjectContext] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "Article", in: managedObjectContext)
            else {
                throw Article.decodeFailure
        }
        
        self.init(entity: entity, insertInto: managedObjectContext)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let publishedAtString = try container.decode(String.self, forKey: .publishedAt)
        
        guard let publishedAt = Article.intoDateFormatter.date(from: publishedAtString) else {
            throw Article.decodeFailure
        }
    
        self.publishedAt = publishedAt
        self.author = try container.decode(String.self, forKey: .author)
        self.title = try container.decode(String.self, forKey: .title)
        
        self.id = publishedAtString + self.title + self.author
        
        
        self.source = try container.decode(Source.self, forKey: .source)
        self.summary = try container.decodeIfPresent(String.self, forKey: .summary)
        
        let urlString = try container.decode(String.self, forKey: .url)
        
        guard let url = URL(string: urlString) else {
            throw Article.decodeFailure
        }
        
        self.url = url
        
        if let urlToImageString = try container.decodeIfPresent(String.self, forKey: .urlToImage),
            let urlToImage = URL(string: urlToImageString) {
            self.urlToImage = urlToImage
        }
        
        self.content = try container.decodeIfPresent(String.self, forKey: .content)
    }
}

//MARK: - Encodable (of Codable)
extension Article {
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(source, forKey: .source)
        try container.encode(author, forKey: .author)
        try container.encode(title, forKey: .title)
        try container.encode(url, forKey: .url)
        try container.encode(urlToImage, forKey: .urlToImage)
        try container.encode(publishedAt, forKey: .publishedAt)
        try container.encode(content, forKey: .content)
    }
}

extension Article: Manageable {
    
    func update(with item: Article) {
        self.source = item.source
        self.summary = item.summary
        self.url = item.url
        self.urlToImage = item.urlToImage
        self.publishedAt = item.publishedAt
        self.content = item.content
        self.id = item.id
        self.author = item.author
        self.title = item.title
    }
}

extension Article {
    func publishedAtPretty() -> String {
        return Article.fromDateFormatter.string(from: self.publishedAt)
    }
}
