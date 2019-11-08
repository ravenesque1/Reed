//
//  ReedTabsView.swift
//  Reed
//
//  Created by Raven Weitzel on 11/7/19.
//  Copyright © 2019 Raven Weitzel. All rights reserved.
//

import SwiftUI

struct ReedTabsView: View {
    var body: some View {
        TabView {
            FeedView()
                .tabItem {
                    Image(systemName: "square.stack.3d.up")
            }
            NewPostView()
                .tabItem {
                    Image(systemName: "text.badge.plus")
            }
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
            }
        }
    }
}

struct ReedTabsView_Previews: PreviewProvider {
    static var previews: some View {
        ReedTabsView()
    }
}
