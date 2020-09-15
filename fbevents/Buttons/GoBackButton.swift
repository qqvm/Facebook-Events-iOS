//
//  MenuButton.swift
//  fbevents
//
//  Created by User on 13.07.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI

struct GoBackButtonView: View {
    @EnvironmentObject var appState: AppState
    let action: () -> Void
    
    var body: some View {
        Button(action: action, label: {
            Image(systemName: "arrow.left")
                .font(.system(size: UserSettings.buttonSize, weight: .light, design: .default))
        })
    }
}

struct GoBackButtonView_Previews: PreviewProvider {
    static var previews: some View {
        GoBackButtonView(action: {}).environmentObject(AppState())
    }
}
