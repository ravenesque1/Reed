//
//  SettingsView.swift
//  Reed
//
//  Created by Raven Weitzel on 11/8/19.
//  Copyright © 2019 Raven Weitzel. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack(spacing: 10.0) {
            Text("Settings")
            
            NavigationLink(destination: OnboardingView()) {
                Text("logout")
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(Color.white)
            }
        }.padding()
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
