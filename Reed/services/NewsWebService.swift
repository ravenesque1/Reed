//
//  NewsWebService.swift
//  Reed
//
//  Created by Raven Weitzel on 12/13/19.
//  Copyright © 2019 Raven Weitzel. All rights reserved.
//

import Foundation
import Combine

//either country, category, or sources is required.
//if sources is specified, country nor category can be specified.
enum TopHeadlineRequiredParameters {
    case country(String)
    case category(String)
    case sources([String])
    
    var description: String {
        switch self {
        case .country:
            return "country"
        case .category:
            return "category"
        case .sources:
            return "sources"
        }
    }
}

enum NewsWebService {
    static let agent = Agent()
    
    static var baseComponents: URLComponents = {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "newsapi.org"
        components.path = "/v2"
        return components
    }()
    
    
    static let apiKey = "YOUR_API_KEY_HERE"
}

extension NewsWebService {
    
    static func loadImage(url: URL) -> AnyPublisher<Data, Error> {
        return agent.dataFromUrl(url)
            .map(\.value)
            .eraseToAnyPublisher()
    }
    
    static func topHeadlines(query: String?,
                             page: Int?,
                             pageSize: Int?,
                             requiredParameters: [TopHeadlineRequiredParameters]) -> AnyPublisher<TopHeadlinesResponse, Error> {
        
        let error = URLError(.badURL)
        
        //enforce rule of at least one TopHeadlineRequiredParameters
        guard requiredParameters.count > 0 else {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        var components = baseComponents
        
        //add top headline endpoint
        components.path += "/top-headlines"
        
        //build parameters
        var queryItems: [URLQueryItem] = []
        
        //(1/2) add required parameters
        
        for item in requiredParameters {
            
            var requiredParamValue: String
            
            switch item {
            case .sources(let sourceList):
                //enforce rule of country and/or category OR sources
                if requiredParameters.count > 1 {
                    return Fail(error: error).eraseToAnyPublisher()
                }
                
                //change source list array into CSV
                requiredParamValue = sourceList.joined(separator: ",")
            case .country(let value), .category(let value):
                requiredParamValue = value
            }
            
            queryItems += [URLQueryItem(name: "\(item.description)", value: requiredParamValue)]
        }
        
        //(2/2) add optional parameters
        
        if let query = query {
            queryItems += [URLQueryItem(name: "q", value: "\(query)")]
        }
        
        if let page = page {
            queryItems += [URLQueryItem(name: "page", value: "\(page)")]
        }
        
        //if not specified, 20. maximum 100
        if let pageSize = pageSize {
            queryItems += [URLQueryItem(name: "pageSize", value: "\(pageSize)")]
        }
        
        components.queryItems = queryItems
        
        return runAuthenticatedRequest(with: components)
    }
    
    static func runAuthenticatedRequest<T: Decodable>(with components: URLComponents) -> AnyPublisher<T, Error> {
        
        let error = URLError(.badURL)
        var authedComponents = components
        var queryItems = authedComponents.queryItems ?? []
        
        queryItems += [URLQueryItem(name: "apiKey", value: "\(NewsWebService.apiKey)")]
        
        //add parameters to query, create request, and run
        authedComponents.queryItems = queryItems
        guard let url = authedComponents.url else {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        let request = URLRequest(url: url)
        
        return agent.run(request)
            .map(\.value)
            .eraseToAnyPublisher()
    }
}
