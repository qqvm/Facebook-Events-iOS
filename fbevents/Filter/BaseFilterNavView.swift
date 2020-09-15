//
//  FilterBaseView.swift
//  fbevents
//
//  Created by User on 05.08.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI


struct BaseFilterNavView<Content: View>: View {
    @EnvironmentObject var appState: AppState
    @Binding var showFilter: Bool
    @Binding var filterOptions: FilterOptions

    let content: Content
    
    init(showFilter: Binding<Bool>, filterOptions: Binding<FilterOptions>, @ViewBuilder content: @escaping () -> Content) {
        self._showFilter = showFilter
        self._filterOptions = filterOptions
        self.content = content()
    }

    var body: some View {
        NavigationView {
            VStack {
                content
                    .padding(.top)
                Spacer()
            }
                .navigationBarTitle(Text("Filter"), displayMode: .inline)
                .navigationBarItems(leading: MenuButtonView(),
                                    trailing:
                    HStack{
                        RestoreButtonView(action: {withAnimation{
                            DispatchQueue.main.async {
                                self.filterOptions.restore()
                            }}})
                        Button(action: {withAnimation{
                                DispatchQueue.main.async {
                                    self.showFilter.toggle()
                                }
                            }}, label: {
                            Image(systemName: "checkmark")
                                .font(.system(size: UserSettings.buttonSize, weight: .light, design: .default))
                        })
                            .padding(.trailing)
                    })
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
