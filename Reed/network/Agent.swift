//
//  Agent.swift
//  Reed
//
//  Created by Raven Weitzel on 12/16/19.
//  Copyright © 2019 Raven Weitzel. All rights reserved.
//

import Combine
import Foundation

struct Agent {
    
    struct Response<T> {
        let value: T
        let response: URLResponse
    }
    
    func dataFromUrl(_ url: URL) -> AnyPublisher<Response<Data>, Error> {
        return URLSession.shared
            .dataTaskPublisher(for: url)
            .tryMap { result -> Response<Data> in
                return Response(value: result.data, response: result.response)
        }
//        .receive(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    func run<T: Decodable>(_ request: URLRequest, _ decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<Response<T>, Error> {
        return URLSession.shared
            
            //create a DataTask as a Combine publisher
            .dataTaskPublisher(for: request)
            .tryMap { result -> Response<T> in
                
                guard let codingUserInfoKeyManagedObjectContext = CodingUserInfoKey.managedObjectContext else {
                    throw URLError(.cannotDecodeRawData)
                }
                
                //add context for Core Data
                let managedObjectContext = CoreDataStack.shared.viewContext
                let decoder = JSONDecoder()
                decoder.userInfo[codingUserInfoKeyManagedObjectContext] = managedObjectContext
                
                //parse JSON (T is decodable)
                let value = try decoder.decode(T.self, from: result.data)
                
                //create response object and pass downstream
                return Response(value: value, response: result.response)
        }
        .receive(on: DispatchQueue.main)
        
        //make generic by returning as instance of AnyPublisher
        .eraseToAnyPublisher()
    }
}
