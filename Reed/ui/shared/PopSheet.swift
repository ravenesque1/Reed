//
//  PopSheet.swift
//  Reed
//
//  Created by Liem Vo
//  https://medium.com/@liemvo/solution-swiftui-actionsheet-crash-on-ipad-f0a5b3a7f755
//

import SwiftUI

struct PopSheet {
    let title: Text
    let message: Text?
    let buttons: [PopSheet.Button]
    
    public init(title: Text, message: Text? = nil, buttons: [PopSheet.Button] = [.cancel()]) {
        self.title = title
        self.message = message
        self.buttons = buttons
    }
    
    
    func actionSheet() -> ActionSheet {
        ActionSheet(title: title, message: message, buttons: buttons.map({ popButton in
            switch popButton.kind {
            case .default: return .default(popButton.label, action: popButton.action)
            case .cancel: return .cancel(popButton.label, action: popButton.action)
            case .destructive: return .destructive(popButton.label, action: popButton.action)
            }
        }))
    }
    
    func popover(isPresented: Binding<Bool>) -> some View {
        VStack {
            self.title.padding(.top)
            Divider()
            List {
                ForEach(Array(self.buttons.enumerated()), id: \.offset) { (offset, button) in
                    VStack {
                        SwiftUI.Button(action: {
                            isPresented.wrappedValue = false
                            DispatchQueue.main.async {
                                button.action?()
                            }
                        }, label: {
                            button.label.font(.subheadline)
                        })
                    }
                }
            }
        }
    }
    
    public struct Button {
        let kind: Kind
        let label: Text
        let action: (() -> Void)?
        enum Kind { case `default`, cancel, destructive }
        
        /// Creates a `Button` with the default style.
        public static func `default`(_ label: Text, action: (() -> Void)? = {}) -> Self {
            Self(kind: .default, label: label, action: action)
        }
        
        /// Creates a `Button` that indicates cancellation of some operation.
        public static func cancel(_ label: Text, action: (() -> Void)? = {}) -> Self {
            Self(kind: .cancel, label: label, action: action)
        }
        
        /// Creates an `Alert.Button` that indicates cancellation of some operation.
        public static func cancel(_ action: (() -> Void)? = {}) -> Self {
            Self(kind: .cancel, label: Text("Cancel"), action: action)
        }
        
        /// Creates an `Alert.Button` with a style indicating destruction of some data.
        public static func destructive(_ label: Text, action: (() -> Void)? = {}) -> Self {
            Self(kind: .destructive, label: label, action: action)
        }
    }
}
