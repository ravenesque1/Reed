//
//  ArticleView.swift
//  Reed
//
//  Created by Raven Weitzel on 1/10/20.
//  Copyright © 2020 Raven Weitzel. All rights reserved.
//

import SwiftUI

struct ArticleView: View {
    
    @ObservedObject var articleViewModel: ArticleViewModel
    
    var body: some View {
        ScrollView {

            //1- title
            Group {
                Text(articleViewModel.article.title)
                    .font(.headline)
                Text(articleViewModel.article.author)
                    .font(.subheadline)
                    .italic()
            }
            .align(.leading)

            Spacer()

            //2- image
            ArticleImage(imageData: articleViewModel.article.imageData)
                .padding(.leading, -20)
                .padding(.trailing, -20)
                .background(Color.green)

            Spacer()

            Text(articleViewModel.article.publishedAtPretty())
                .font(.caption)
                .align(.trailing)

            Spacer()

            //detail
            Text(articleViewModel.article.content ?? "No content.")
                .font(.body)
                .align(.leading)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 30)

            //source
            VStack {

                HStack {
                    Spacer()
                }

                Group {
                    Button(action: self.articleViewModel.toggleViewSource) {
                        Text(self.articleViewModel.sourceButtonTitle)
                    }

                    Spacer()

                    if articleViewModel.viewSource {

                        Text(self.articleViewModel.article.source.name)
                        Text("id: \(self.articleViewModel.article.source.id)")
                            .italic()
                            .font(.caption)
                    }

                    Spacer(minLength: 30)

                    //external link
                    ReedButton(
                        color: .blue,
                        title: "View in Safari",
                        inverted: true,
                        action: {
                            self.articleViewModel.openInSafari()
                    })
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal)
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
