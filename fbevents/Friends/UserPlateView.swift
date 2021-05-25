//
//  FriendPlateView.swift
//  fbevents
//
//  Created by User on 14.08.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI

struct UserPlateView: View {
    @EnvironmentObject var appState: AppState
    @State var friend: User
    @State private var isUserFavorite = false
    
    var body: some View {
        HStack{
            if self.appState.settings.downloadImages && friend.picture != ""{
                WebImage(url: URL(string: friend.picture))
                    .placeholder(Image(systemName: "photo"))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 70, alignment: .leading)
                    .padding(.trailing)
            }
            Text(friend.name)
                .font(.title)
                .fontWeight(.thin)
            Spacer()
            Button(action: {
                self.isUserFavorite.toggle()
                if self.isUserFavorite{
                    _ = self.friend.save(dbPool: self.appState.dbPool!)
                }
                else{
                    _ = self.friend.delete(dbPool: self.appState.dbPool!)
                }
            }){
                Image(systemName: self.isUserFavorite ? "star.fill" : "star")
                    .foregroundColor(.blue)
            }.padding(.trailing)
        }.onAppear(){
            self.isUserFavorite = self.friend.exists(dbPool: self.appState.dbPool!)
        }
    }
}
