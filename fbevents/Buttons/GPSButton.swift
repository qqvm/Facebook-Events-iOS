//
//  MenuButton.swift
//  fbevents
//
//  Created by User on 13.07.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI

struct GPSButtonView: View {
    @EnvironmentObject var appState: AppState
    let action: () -> Void
    
    var body: some View {
        Button(action: action, label: {
            Image(systemName: "location.circle")
                .font(.system(size: UserSettings.buttonSize, weight: .light, design: .default))
        })
            .padding(.leading)
    }
}

struct GPSButtonView_Previews: PreviewProvider {
    static var previews: some View {
        GPSButtonView(action: {}).environmentObject(AppState())
    }
}

