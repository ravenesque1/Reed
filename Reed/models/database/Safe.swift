//
//  Safe.swift
//  Reed
//
//  Created by Raven Weitzel on 1/7/20.
//  Copyright © 2020 Raven Weitzel. All rights reserved.
//

///When working with an array response, and some items may be corrupted, use this class
///to prevent one corrupted item from ruining the array. For example, when articles come in,
///some do not follow the rules (a missing author for example). When using combine (and
///tryMap specifically in Agent.swift), a corrupted Article will end the entire stream (if 20 articles
///are fetched and the 9th is corrupted, a user will end up with 9 visible Articles). Use this class
///when one failed item should not stop the whole show.
public struct Safe<Base: Decodable>: Decodable {
    
    let value: Base?
    
    public init(from decoder: Decoder) throws {
        do {
            let container = try decoder.singleValueContainer()
            self.value = try container.decode(Base.self)
        } catch {
            print("Warning! Failed to decode Safe \(Base.self), likely due to corruption.")
//            print("Warning! \(error)\nFailed to decode \(Base.self)")
            self.value = nil
        }
    }
}
