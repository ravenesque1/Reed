//
//  ArticleView.swift
//  Reed
//
//  Created by Raven Weitzel on 1/10/20.
//  Copyright © 2020 Raven Weitzel. All rights reserved.
//

import SwiftUI

struct ArticleView: View {
    
    var articleViewModel: ArticleViewModel
    
    var body: some View {
        VStack {
            Text(articleViewModel.article.title)
                .font(.headline)
            
            Spacer()
            
            Text(articleViewModel.article.content ?? "No content.")
                .font(.body)
        }
    }
}

#if DEBUG
struct ArticleView_Previews: PreviewProvider {
    static var previews: some View {
        ArticleView(articleViewModel: ArticleViewModel.sample())
            .environment(\.managedObjectContext, CoreDataStack.shared.persistentContainer.viewContext)
    }
}
#endif
