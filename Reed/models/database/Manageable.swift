//
//  Manageable.swift
//  Reed
//
//  Created by Raven Weitzel on 12/17/19.
//  Copyright © 2019 Raven Weitzel. All rights reserved.
//

import CoreData

/*  This is a protocol to managed API-fetched objects with Core Data
 *  NSManagedObject is the Core Data "entity"
 *  Codable allows for receiving object in json format via API
 *  update function allows for saving json to Core Data
 *  Identifiable enforces id as a single source of truth for entities
 */
protocol Manageable: NSManagedObject, Codable, Identifiable {
    func update(with item: Self)
}
