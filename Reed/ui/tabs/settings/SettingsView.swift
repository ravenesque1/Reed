//
//  SettingsView.swift
//  Reed
//
//  Created by Raven Weitzel on 11/8/19.
//  Copyright © 2019 Raven Weitzel. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var userAuth: UserSettings
    
    var body: some View {
        ReedHiddenNavBarView {
            VStack {
                VStack(spacing: 10.0) {
                    
                    HStack {
                        Text("Settings")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        self.userAuth.isLoggedIn = false
                    }) {
                        Text("logout")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(Color.white)
                    }
                    
                    Spacer()

                }
                .padding(.init(top: 20.0, leading: 0.0, bottom: 0.0, trailing: 0.0))
                
                Spacer()
            }
            .padding()
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
