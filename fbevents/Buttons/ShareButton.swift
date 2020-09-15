//
//  MenuButton.swift
//  fbevents
//
//  Created by User on 13.07.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI

struct ShareButtonView: View {
    @EnvironmentObject var appState: AppState
    let action: () -> Void
    
    var body: some View {
        Button(action: action, label: {
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: UserSettings.buttonSize - 5, weight: .light, design: .default))
        })
            .padding(.bottom, 5)
            .padding(.trailing)
    }
}

struct ShareButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ShareButtonView(action: {}).environmentObject(AppState())
    }
}
