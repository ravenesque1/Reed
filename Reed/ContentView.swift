//
//  ContentView.swift
//  Reed
//
//  Created by Raven Weitzel on 11/7/19.
//  Copyright © 2019 Raven Weitzel. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var userAuth: UserSettings
    
    @ViewBuilder var body: some View {
        if userAuth.isLoggedIn {
            ReedTabsView()
        } else {
            OnboardingView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
