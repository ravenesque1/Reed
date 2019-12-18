//
//  TopHeadlinesResponse.swift
//  Reed
//
//  Created by Raven Weitzel on 12/18/19.
//  Copyright © 2019 Raven Weitzel. All rights reserved.
//

struct TopHeadlinesResponse: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case status
        case totalResults
        case articles
    }
    
    var status: String
    var totalResults: Int
    var articles: [Article]
}
