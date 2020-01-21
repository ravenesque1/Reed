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

        /*
         Using the native TabView would be nice, but state is not preserved
         on switch. This may be by design, but for now, using the UIKit tab
         view is the best way to remember state.
         */
        
        UIKitTabView([
            UIKitTabView.Tab(view: FeedView(), systemImage: "square.stack.3d.up"),
            UIKitTabView.Tab(view: NewPostView(), systemImage: "text.badge.plus"),
            UIKitTabView.Tab(view: SettingsView(), systemImage: "gear")
        ])
    }
}

struct ReedTabsView_Previews: PreviewProvider {
    static var previews: some View {
        ReedTabsView()
    }
}
