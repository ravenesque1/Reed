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

//MARK: - Syncing: Saving Items Added to the Context already via Decoder
extension CoreDataStack {
    
    //sync list of "Safe" items with no feedback
    func silentSafeSync<T: Manageable>(items: [Safe<T>]) {
        _ = safeSync(items: items)
    }
    
    //syncs "Safe" items, removing corrupted ones in the process
    func safeSync<T: Manageable>(items: [Safe<T>]) -> Bool {
        var successful = false
        
        viewContext.performAndWait {
            
            //0 - items put into context upon decoding, so remove Safe.value == nil
            removeCorrputed(ofType: T.self)
            
            //1 - save insertion from decoding and corrpution removal
            do {
                try saveContext()
            } catch {
                print("Error: \(error)\n unable to save view context in safe sync")
            }
            
            successful = true
        }   
        return successful
    }
}

//MARK: - Update
extension CoreDataStack {
    
    ///updates the database and saves chnages
    private func update<T: Manageable>(_ items: [T]) throws {
        for item in items {
            guard let newItem = NSEntityDescription.insertNewObject(forEntityName: "\(T.self)", into: viewContext) as? T else {
                print("Error: Failed to make new item.")
                return
            }
            newItem.update(with: item)
        }
        
        try save(changeType: .insertion)
    }
    
    /**
     Delete previous instances of [T] from context using IDs, and saves provided ones
    
     - Warning:
     This function will delete objects already saved, not the new ones in [T]
    */
    func forceUpdate<T: Manageable>(items: [T]) -> Bool {
        
        var successful = false
        
        viewContext.performAndWait {
            
            //0 - save all context changes before syncing
            do {
                try saveContext()
            } catch {
                print("Error: \(error)\nCould not save context.")
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
                try update(items)
            } catch {
                print("Error: \(error)\nCould not insert new items and save changes.")
                return
            }
            
            successful = true
        }
        
        return successful
    }
    
    ///forcibly update a single item convenience method
    func forceUpdate<T: Manageable & Identifiable>(item: T) -> Bool {
        return forceUpdate(items: [item])
    }
}

//MARK: - Delete
extension CoreDataStack {
    
    ///when Safe managed objects are used, this method removes the nil objects created
    func removeCorrputed<T: Manageable>(ofType: T.Type) {
        viewContext.insertedObjects
            .compactMap { $0 as? T }
            .filter { $0.id is String }
            .filter { ($0.id as! String) == "" }
            .forEach { viewContext.delete($0) }
    }
    
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

//MARK: - Save Changes
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
