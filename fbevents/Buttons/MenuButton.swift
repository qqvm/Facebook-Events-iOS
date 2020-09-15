//
//  MenuButton.swift
//  fbevents
//
//  Created by User on 13.07.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI

struct MenuButtonView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Button(action: {
            withAnimation{
                self.appState.showMenu.toggle()
            }
        }, label: {
            Image(systemName: "line.horizontal.3")
                .font(.system(size: UserSettings.buttonSize, weight: .light, design: .default))
        })
            .padding(.leading)
    }
}

struct MenuButtonView_Previews: PreviewProvider {
    static var previews: some View {
        MenuButtonView().environmentObject(AppState())
    }
}
