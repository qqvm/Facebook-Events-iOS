//
//  FriendsBasicNavView.swift
//  fbevents
//
//  Created by User on 12.09.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI


struct FriendsBasicNavView: View {
    @EnvironmentObject var appState: AppState
    @State var isFavoriteTab = true
    @State var searchKeyword = ""
    @State var showSearchField = false
    @State var performReload = false
    
    var body: some View{
        VStack{
            FriendsBasicView(searchKeyword: $searchKeyword, showSearchField: $showSearchField, performReload: $performReload, isFavoriteTab: isFavoriteTab)
        }.navigationBarItems(leading: MenuButtonView(),
            trailing:
            HStack{
                HStack(alignment: .center, spacing: .zero){
                    RestoreButtonView(){
                        self.searchKeyword = ""
                        self.performReload.toggle()
                    }.disabled(self.searchKeyword == "")
                    SearchButtonView(){
                        withAnimation{
                            self.showSearchField.toggle()
                        }
                    }
                }.disabled(!self.appState.isInternetAvailable && !isFavoriteTab)
            })
    }
}
