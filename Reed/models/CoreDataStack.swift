//
//  CoreDataStack.swift
//  Reed
//
//  Created by Raven Weitzel on 12/16/19.
//  Copyright © 2019 Raven Weitzel. All rights reserved.
//

import CoreData

enum DatabaseChangeType {
    case insertion
    case deletion([NSManagedObjectID])
}

class CoreDataStack {
    
    private init() {}
    static let shared = CoreDataStack()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Reed")
        
        container.loadPersistentStores(completionHandler: { _, error in
            guard let error = error as NSError? else { return }
            fatalError("Unresolved error: \(error), \(error.userInfo)")
        })
        
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.undoManager = nil
        container.viewContext.shouldDeleteInaccessibleFaults = true
        
        //auto-merging changes from parent allows backgrounded context to save data
        //and propagate changes to the viewContext
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
}

//MARK: - Syncing (Delete, then Update)
extension CoreDataStack {
    
    //sync list of items with no feedback
    func silentSync<T: Manageable>(items: [T]) {
        _ = sync(items: items)
    }
    
    ///sync a list of items, returns true if successful
    func sync<T: Manageable>(items: [T]) -> Bool {
        
        var successful = false
        
        viewContext.performAndWait {
            
            //0 - save all context changes before syncing
            do {
                try saveContext()
            } catch {
                print("Error: \(error)\nCould not save changes.")
                return
            }
            
            //1 - remove old versions of items if they exist, saving changes
            do {
                try deleteOldVersionsOfItems(items)
            } catch {
                print("Error: \(error)\nCould not batch delete existing records")
                return
            }

            //2 - add new items and save changes
            do {
                try insert(items)
            } catch {
                print("Error: \(error)\nCould not save changes.")
                return
            }

            successful = true
        }
        
        return successful
    }
    
    ///sync a single item convenience method
    func sync<T: Manageable & Identifiable>(item: T) -> Bool {
        return sync(items: [item])
    }
}

//MARK: - Insertion
extension CoreDataStack {
    
    ///updates the database and saves chnages
    private func insert<T: Manageable>(_ items: [T]) throws {
        for item in items {
            guard let newItem = NSEntityDescription.insertNewObject(forEntityName: "\(T.self)", into: viewContext) as? T else {
                print("Error: Failed to make new item.")
                return
            }
            newItem.update(with: item)
        }
        
        try save(changeType: .insertion)
    }
}

//MARK: - Deletion
extension CoreDataStack {
    
    ///deletes all articles and saves changes
    func deleteAllManagedObjectsOfEntityName(_ entityName: String) {

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs
        
        do {
            try performDeleteRequest(batchDeleteRequest)
        } catch {
            print("Error: \(error)\nCould not delete all articles.")
            return
        }
    }
    
    ///deletes old items by ID and tries to save changes via merge
    private func deleteOldVersionsOfItems<T: Identifiable>(_ items: [T]) throws {
        
        let batchDeleteRequest = generateBatchDeleteRequest(from: items)

        try performDeleteRequest(batchDeleteRequest)
    }
    
    ///performs database deletion and saves changes via merge
    private func performDeleteRequest(_ deleteRequest: NSBatchDeleteRequest) throws {
        let batchDeleteResult = try? viewContext.execute(deleteRequest) as? NSBatchDeleteResult

        if let deletedObjectIds = batchDeleteResult?.result as? [NSManagedObjectID] {
            try save(changeType: .deletion(deletedObjectIds))
            
        }
    }
    ///creates a request containing the IDs of the to-be-deleted items
    private func generateBatchDeleteRequest<T: Identifiable>(from items: [T]) -> NSBatchDeleteRequest {
        
        let matchingItemRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Article")
        
        let articleIds = items.compactMap{ $0.id }
        matchingItemRequest.predicate = NSPredicate(format: "id in %@", articleIds)
        
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: matchingItemRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs
        
        return batchDeleteRequest
    }
}

//MARK: - Saving Changes
extension CoreDataStack {
    
    //saves change to database
    private func save(changeType: DatabaseChangeType) throws {
        switch changeType {
        case .insertion:
            try saveContext(reset: true)
        case .deletion(let deletedObjectIds):
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: [NSDeletedObjectsKey: deletedObjectIds],
            into: [self.viewContext])
        }
    }
    
    //saving changes made to the database
    func saveContext(reset: Bool = false) throws {
        if viewContext.hasChanges {
            try viewContext.save()
            if reset {
                viewContext.reset()
            }
        }
    }
}
