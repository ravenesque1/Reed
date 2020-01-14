//
//  FilteredList.swift
//  Reed
//
//  Created by Raven Weitzel on 1/13/20.
//  Copyright © 2020 Raven Weitzel. All rights reserved.
//

import Combine
import CoreData
import SwiftUI

struct FilteredList<T: NSManagedObject, Content: View>: View {
    var fetchRequest: FetchRequest<T>
    var singers: FetchedResults<T> { fetchRequest.wrappedValue }

    // this is our content closure; we'll call this once for each item in the list
    let content: (T) -> Content

    var body: some View {
        List(fetchRequest.wrappedValue, id: \.self) { singer in
            self.content(singer)
        }
    }

    init(filterKey: String, filterValue: String, @ViewBuilder content: @escaping (T) -> Content) {
        fetchRequest = FetchRequest<T>(entity: T.entity(), sortDescriptors: [], predicate: NSPredicate(format: "%K BEGINSWITH %@", filterKey, filterValue))
        self.content = content
    }
}
