//
//  UserAuth.swift
//  Reed
//
//  Created by Raven Weitzel on 11/7/19.
//  Copyright © 2019 Raven Weitzel. All rights reserved.
//

import Combine

class UserSettings: ObservableObject {
    
    let didChange = PassthroughSubject<UserSettings,Never>()
    
    var isLoggedIn = false {
        didSet {
            didChange.send(self)
        }
    }
    
    func login() {
        self.isLoggedIn = true
    }
}



