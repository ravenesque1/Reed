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
    @ObservedObject private var settingsViewModel = SettingsViewModel()
    
    
    
    var body: some View {
        VStack {
            
            VStack(spacing: 10.0) {
                
                //TODO: determine if NavigationBar should be hidden and
                //thus if the title needs to be displayed like this
                HStack {
                    Text("Settings")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                }
                
                Spacer()
                
                clearCacheButton()
                    .alert(isPresented: self.$settingsViewModel.showDeleteConfirmation, content: clearCacheAlert)
                
                logoutButton()
                
                Spacer()
            }
            .padding(.init(top: 20.0, leading: 0.0, bottom: 0.0, trailing: 0.0))
            
            Spacer()
        }
        .padding()
        .navigationBarTitle(Text("Settings"))
    }
}

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
#endif

//MARK: - Complex UI
extension SettingsView {
    
    private func clearCacheButton() -> ReedButton {
        return ReedButton(color: .red,
                          title: "clear cache",
                          action: {
                            self.settingsViewModel.showDeleteConfirmation = true
        })
    }
    
    private func logoutButton() -> ReedButton {
        return  ReedButton(color: .red,
                           title: "logout",
                           inverted: true,
                           action: {
                            self.userAuth.logout()
        })
        
    }
    
    private func clearCacheAlert() -> Alert {
        return Alert(title: Text("Are you sure you want to clear the cache?"),
                     message: Text("This will remove all articles. This action cannot be undone."),
                     primaryButton: .cancel(),
                     secondaryButton: .destructive(Text("Remove All Articles"), action: {
                        self.settingsViewModel.deleteAllArticles() {
                            self.userAuth.recentlyClearedCache = true
                        }
                     }))
    }
}
