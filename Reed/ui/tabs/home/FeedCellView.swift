//
//  FeedCellView.swift
//  Reed
//
//  Created by Raven Weitzel on 12/18/19.
//  Copyright © 2019 Raven Weitzel. All rights reserved.
//

import SwiftUI

struct FeedCellView: View {
    
    var article: Article
    var idx: Int = 0
    
    var body: some View {
        HStack {
            Image(systemName: "photo")
            VStack(alignment: .leading) {
                Text(article.title)
                Text(article.summary)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
}
