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
                    
                    ReedButton(
                        color: .blue,
                        title: "login",
                        inverted: true,
                        action: {
                            self.userAuth.isLoggedIn = true
                    })
                    
                    ReedButton(
                        color: .green,
                        title: "sign up",
                        action: {
                            print("user wants to sign up")
                    })
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
