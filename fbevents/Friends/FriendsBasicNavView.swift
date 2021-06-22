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
    
    var body: some View{
        VStack{
            FriendsBasicView(searchKeyword: $searchKeyword, showSearchField: $showSearchField, isFavoriteTab: isFavoriteTab)
        }.navigationBarItems(leading: MenuButtonView(),
            trailing:
            HStack{
                HStack(alignment: .center, spacing: .zero){
                    RestoreButtonView(){
                        DispatchQueue.main.async {
                            self.searchKeyword = ""
                            NotificationCenter.default.post(name: Notification.Name("NeedFriendsRefresh"), object: true)
                        }
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
