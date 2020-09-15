//
//  MenuButton.swift
//  fbevents
//
//  Created by User on 13.07.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI

struct RefreshButtonView: View {
    @EnvironmentObject var appState: AppState
    let action: () -> Void
    
    var body: some View {
        Button(action: action, label: {
            Image(systemName: "arrow.2.circlepath")
                .font(.system(size: UserSettings.buttonSize, weight: .light, design: .default))
        })
            .padding(.trailing)
    }
}

struct RefreshButtonView_Previews: PreviewProvider {
    static var previews: some View {
        RefreshButtonView(action: {}).environmentObject(AppState())
    }
}
