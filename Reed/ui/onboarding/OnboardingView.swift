//
//  OnboardingView.swift
//  Reed
//
//  Created by Raven Weitzel on 11/7/19.
//  Copyright © 2019 Raven Weitzel. All rights reserved.
//

import SwiftUI

struct OnboardingView: View {
    var body: some View {
        ReedHiddenNavBarView {
            NavigationView {
                VStack(spacing: 10.0) {
                        Text("welcome, this is onboarding")
                        
                    ReedNavigationLink(
                        color: .blue,
                        title: "login",
                        destination: ReedTabsView().any)

                        
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
