//
//  SettingsViewModel.swift
//  Reed
//
//  Created by Raven Weitzel on 1/16/20.
//  Copyright © 2020 Raven Weitzel. All rights reserved.
//

import Foundation

class SettingsViewModel: ReedViewModel {
    
    @Published var deleting: Bool = false
    @Published var showDeleteConfirmation: Bool = false {
        willSet {
            self.objectWillChange.send()
        }
    }
    
    func deleteAllArticles(completion: @escaping () -> ()) {
        self.deleting = true
        //TODO: Don't let user leave until all is deleted
        CoreDataStack.shared.deleteAllManagedObjectsOfEntityName("Article") {
            self.deleting = false
            completion()
        }
    }
}
