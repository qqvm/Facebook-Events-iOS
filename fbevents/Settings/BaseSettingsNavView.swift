//
//  SettingsView.swift
//  fbevents
//
//  Created by User on 21.06.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI


struct BaseSettingsNavView<Content: View>: View {
    @EnvironmentObject var appState: AppState
    
    let content: Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 5){
            content
        }
        .navigationBarTitle(Text("Settings"), displayMode: .inline)
        .navigationBarItems(leading: MenuButtonView(),
                            trailing: RestoreButtonView(action: {withAnimation{self.appState.settings.restoreSettings()}}))
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct SettingsBaseView_Previews: PreviewProvider {
    static var previews: some View {
        BaseSettingsNavView(){
            Text("Sample")
        }.environmentObject(AppState())
    }
}
