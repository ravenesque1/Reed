//
//  ReedNavigationLink.swift
//  Reed
//
//  Created by Raven Weitzel on 11/8/19.
//  Copyright © 2019 Raven Weitzel. All rights reserved.
//

import SwiftUI

struct ReedNavigationLink: View {
    
    var color: Color
    var title: String
    var destination: AnyView
    var inverted: Bool = false
    var cornerRadius: CGFloat = 10.0
    var lineWidth: CGFloat = 3.0
    var minWidth: CGFloat = 0.0
    var maxWidth: CGFloat = .infinity
    
    var body: some View {
        
        NavigationLink(destination: destination) {
            
            if inverted {
                Text(title)
                    .frame(minWidth: minWidth, maxWidth: maxWidth)
                    .padding()
                    .foregroundColor(Color.white)
                    .background(color)
                    .cornerRadius(cornerRadius)
            } else {
                Text(title)
                    .frame(minWidth: minWidth, maxWidth: maxWidth)
                    .padding()
                    .foregroundColor(color)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(color, lineWidth: lineWidth)
                )
            }
        }
    }
}

struct ReedNavigationLink_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ReedNavigationLink(
                color: .green,
                title: "login",
                destination: ReedTabsView().any)
            
            ReedNavigationLink(
                color: .red,
                title: "logout",
                destination: OnboardingView().any,
                inverted: true)
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}
