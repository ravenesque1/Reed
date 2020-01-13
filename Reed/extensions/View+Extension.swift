//
//  View+Extension.swift
//  Reed
//
//  Created by Raven Weitzel on 11/8/19.
//  Copyright © 2019 Raven Weitzel. All rights reserved.
//

import SwiftUI

extension View {
    var any: AnyView {
        return AnyView(self)
    }

    func align(_ inset: Alignment) -> some View {
       return self
            .frame(maxWidth: .infinity, alignment: inset)
    }
    
    //returns a view that fades at the bottom
    //(mainly for Text)
    func faded() -> some View {
        let stops = [
            Gradient.Stop(color: .black, location: 0.7),
            Gradient.Stop(color: .clear, location: 1) ]
        
        return ZStack {
            
            //understand the size of the View...
            self
                .foregroundColor(.clear)
            
            //...and use that to determine gradient size
            LinearGradient(gradient: Gradient(stops: stops),
                           startPoint: .top,
                           endPoint: .bottom)
                .mask(self
            )
        }
    }
}
