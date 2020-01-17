//
//  UserAuth.swift
//  Reed
//
//  Created by Raven Weitzel on 11/7/19.
//  Copyright © 2019 Raven Weitzel. All rights reserved.
//

import Combine
import UIKit

class UserSettings: ObservableObject {
    
    @Published var isLoggedIn : Bool = false
    @Published var recentlyClearedCache: Bool = false
    
    private enum Setting: String {
        case loggedIn = "logged_in"
    }
    
    init() {
        self.updateLoggedIn()
    }

    func login() {
        UserDefaults.standard.set(true, forKey: Setting.loggedIn.rawValue)
        self.updateLoggedIn()
    }
    
    func logout() {
        UserDefaults.standard.set(false, forKey: Setting.loggedIn.rawValue)
        self.updateLoggedIn()
    }
    
    private func updateLoggedIn() {
        isLoggedIn = UserDefaults.standard.bool(forKey: Setting.loggedIn.rawValue)
    }
}



