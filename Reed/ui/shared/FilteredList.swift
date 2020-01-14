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

struct FilteredList<T: Manageable, Content: View>: View {
    var fetchRequest: FetchRequest<T>
    var item: FetchedResults<T> { fetchRequest.wrappedValue }

    // this is our content closure; we'll call this once for each item in the list
    let content: (Int, T, Int) -> Content

    var body: some View {
        
        List (fetchRequest.wrappedValue.enumerated().map { $0 }, id: \.self.1.id) { (idx, article) in
            self.content(idx, article, self.fetchRequest.wrappedValue.count)
        }
    }

    init(predicate: NSPredicate?, @ViewBuilder content: @escaping (Int, T, Int) -> Content) {
        fetchRequest = FetchRequest<T>(entity: T.entity(), sortDescriptors: [], predicate: predicate)
        self.content = content
    }
}
