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
        ScrollView(showsIndicators: false) {
            
            //1- title and date
            Group {
                Text(articleViewModel.article.title)
                    .font(.headline)
                Text(articleViewModel.article.publishedAtPretty())
                    .font(.caption)
                
            }
            .align(.leading)
            
            Spacer()
            
            //2- image and author
            ArticleImage(articleImageViewModel: articleViewModel.articleImageViewModel)
                .padding(.leading, -20)
                .padding(.trailing, -20)
            
            Spacer()
            
            Text(articleViewModel.article.author)
                .font(.subheadline)
                .italic()
                .align(.leading)
            
            Spacer(minLength: 30)
            
            //3- summary
            VStack {
                Group {
                    if articleViewModel.article.summary != nil {
                        Text("Summary: ")
                            .bold()
                        Text(articleViewModel.article.summary!)
                    } else {
                        Text("No summary available.")
                    }
                }
                    
                .font(.body)
                .align(.leading)
                .padding(5)
            }
            .border(Color.black)
            
            Spacer(minLength: 30)
            
            //4- preview and safari link
            VStack {
                
                if self.articleViewModel.article.content != nil {
                    Button(action: self.articleViewModel.toggleViewSource) {
                        Text(self.articleViewModel.previewButtonTitle)
                            .foregroundColor(self.articleViewModel.showPreview ? .red : .blue)
                    }
                    .align(.leading)
                    
                    if articleViewModel.showPreview {
                        Text(self.articleViewModel.article.content!)
                            .font(.body)
                            .faded()
                    }
                }
                
                Spacer(minLength: 30)
                
                ReedButton(
                    color: .blue,
                    title: self.articleViewModel.viewButtonTitle,
                    inverted: true,
                    action: {
                        self.articleViewModel.openInSafari()
                })
            }
                //maintain view size when preview is toggled
                .fixedSize(horizontal: false, vertical: true)
            
            //5- a little space at the bottom
            Spacer()
        }
        .padding(.horizontal)
        .navigationBarTitle(articleViewModel.article.source.name)
    }
}

#if DEBUG
struct ArticleView_Previews: PreviewProvider {
    static var previews: some View {
        ArticleView(articleViewModel: ArticleViewModel.longSample())
            .environment(\.managedObjectContext, CoreDataStack.shared.persistentContainer.viewContext)
    }
}
#endif
