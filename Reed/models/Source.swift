//
//  Source.swift
//  Reed
//
//  Created by Raven Weitzel on 12/16/19.
//  Copyright © 2019 Raven Weitzel. All rights reserved.
//

import CoreData

class Source: NSManagedObject {
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case content  = "description"
        case url
        case category
        case country
        case language
    }
    
    @NSManaged var id: String
    @NSManaged var name: String
    @NSManaged var content: String?
    @NSManaged var url: URL?
    @NSManaged var category: String?
    @NSManaged var country: String?
    @NSManaged var language: String?
    
    //Mark: - Decodable (of Codable)
    required convenience init(from decoder: Decoder) throws {
        
        let errorMessage = "Failed to decode Source"
        
        guard let codingUserInfoKeyManagedObjectContext = CodingUserInfoKey.managedObjectContext,
            let managedObjectContext = decoder.userInfo[codingUserInfoKeyManagedObjectContext] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "Source", in: managedObjectContext) else {
            fatalError(errorMessage)
        }

        self.init(entity: entity, insertInto: managedObjectContext)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        var id = try container.decodeIfPresent(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        
        if id == nil {
            id = self.name.components(separatedBy: " ").joined(separator: "-")
        }
        
        self.id = id!
        
        self.content = try container.decodeIfPresent(String.self, forKey: .content)
        
        if let urlString = try container.decodeIfPresent(String.self, forKey: .url),
            let url = URL(string: urlString) {
            self.url = url
        }
        
        self.category = try container.decodeIfPresent(String.self, forKey: .category)
        self.country = try container.decodeIfPresent(String.self, forKey: .country)
        self.language = try container.decodeIfPresent(String.self, forKey: .language)
    }
}

// MARK: - Encodable (of Codable)
extension Source {
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(content, forKey: .content)
        try container.encode(url, forKey: .url)
        try container.encode(category, forKey: .category)
        try container.encode(country, forKey: .country)
        try container.encode(language, forKey: .language)
    }
}

extension Source: Manageable {
    
    func update(with item: Source) {
        self.id = item.id
        self.name = item.name
        self.content = item.content
        self.url = item.url
        self.category = item.category
        self.country = item.country
        self.language = item.language
    }
}
