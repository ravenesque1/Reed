//
//  ReedButton.swift
//  Reed
//
//  Created by Raven Weitzel on 12/10/19.
//  Copyright © 2019 Raven Weitzel. All rights reserved.
//

import SwiftUI

struct ReedButton: View {
    
    var color: Color
    var title: String
    var inverted: Bool = false
    var cornerRadius: CGFloat = 10.0
    var lineWidth: CGFloat = 3.0
    var minWidth: CGFloat = 0.0
    var maxWidth: CGFloat = .infinity
    var action: () -> ()
    
    var body: some View {
        Button(action: {
            self.action()
        }) {
            Text(title)
                .frame(minWidth: minWidth, maxWidth: maxWidth)
                .padding()
                .background(color)
                .foregroundColor(Color.white)
        }
    }
}

#if DEBUG
struct ReedButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ReedButton(
                color: .blue,
                title: "login",
                action: {
                    print("Info: User would like to login")
            })
            
            ReedButton(
                color: .red,
                title: "logout",
                inverted: true,
                action: {
                    print("Info: User would like to logout")
            })
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}
#endif
