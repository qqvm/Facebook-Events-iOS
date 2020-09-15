//
//  MenuButton.swift
//  fbevents
//
//  Created by User on 13.07.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI

struct RestoreButtonView: View {
    @EnvironmentObject var appState: AppState
    let action: () -> Void
    
    var body: some View {
        Button(action: action, label: {
            Image(systemName: "arrow.counterclockwise")
                .font(.system(size: UserSettings.buttonSize, weight: .light, design: .default))
        })
            .padding(.bottom, 5)
            .padding(.trailing)
    }
}

struct RestoreButtonView_Previews: PreviewProvider {
    static var previews: some View {
        RestoreButtonView(action: {}).environmentObject(AppState())
    }
}
