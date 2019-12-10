//
//  OnboardingView.swift
//  Reed
//
//  Created by Raven Weitzel on 11/7/19.
//  Copyright © 2019 Raven Weitzel. All rights reserved.
//

import SwiftUI

struct OnboardingView: View {
    
    @EnvironmentObject var userAuth: UserSettings

    
    var body: some View {
        
        ReedHiddenNavBarView {
            NavigationView {
                VStack(spacing: 10.0) {
                        Text("welcome, this is onboarding")
                        
                    Button(action: {
                        self.userAuth.isLoggedIn = true
                    }) {
                        Text("login")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(Color.white)
                    }

                        
                        Button(action: {
                            print("user wants to sign up")
                        }) {
                            Text("sign up")
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(Color.white)
                        }
                    }
                .padding()
            }
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
