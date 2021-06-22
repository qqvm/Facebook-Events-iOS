//
//  FriendsBaseView.swift
//  fbevents
//
//  Created by User on 14.08.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI


struct FriendsBasicView: View {
    @EnvironmentObject var appState: AppState
    @State var isSubview = false
    @State var originId = 0
    @State var friends = [User]()
    @Binding var searchKeyword: String
    @Binding var showSearchField: Bool
    @State var isFavoriteTab = true
    @State var friendPager = NetworkPager()
    @State var friendsInFocus = [Int](){
        didSet{
            //self.appState.logger.log("LOADED", friendsInFocus.count, friendsInFocus.last, friends.count, friends.last?.id)
            if !isSubview && self.appState.loadComplete && self.appState.settings.token != "" && self.friendPager.canProceed &&
                self.appState.isInternetAvailable /*&& friendsInFocus.count > 0 &&
                friendsInFocus.count <= (friends.count > 10 ? 10 : friends.count)*/ &&
            friendsInFocus.contains(friends.last?.id ?? -1) && friendsInFocus.last != oldValue.last{
                self.loadMyFriendsPage()
            }
        }
    }
    
    var body: some View {
        VStack{
            VStack{
                if showSearchField{
                    HStack{
                        TextField("Search friends", text: self.$searchKeyword){
                            self.refreshFriends()
                        }
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        GoButtonView(){
                            DispatchQueue.main.async {
                                self.refreshFriends()
                            }
                        }
                    }.disabled(!self.appState.isInternetAvailable && !isFavoriteTab)
                    .padding(.horizontal)
                    .padding(.top)
                }
                VStack{
                    List{
                        if friends.count == 0{
                            EmptySection()
                        }
                        else{
                            Section{
                                ForEach(friends, id: \.id){(friend: User) in
                                    NavigationLink(destination: UserEventsView(isSubview: self.isSubview, originId: self.originId, user: friend)){
                                            UserPlateView(friend: friend)
                                        .onAppear(){
                                            if !self.isSubview && !self.isFavoriteTab{
                                                DispatchQueue.main.async {
                                                    if !self.friendsInFocus.contains(friend.id){
                                                        self.friendsInFocus.append(friend.id)
                                                    }
                                                }
                                            }
                                        }
                                        .onDisappear(){
                                            if !self.isSubview && !self.isFavoriteTab{
                                                DispatchQueue.main.async {
                                                    self.friendsInFocus.removeAll(where: {$0 == friend.id})
                                                }
                                            }
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                    }//.listStyle(PlainListStyle())
                }.padding()
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("NeedFriendsRefresh"))) {
                if $0.object != nil {
                    DispatchQueue.main.async {
                        withAnimation{
                            self.showSearchField = false
                        }
                        self.refreshFriends()
                    }
                }
            }
            .onAppear(){
                if self.friends.count == 0{
                    if self.isFavoriteTab{
                        self.loadFriendsFromDB()
                    }
                    else if self.appState.settings.userId > 0 && !self.isSubview{
                        if self.friends.count == 0 && self.appState.isInternetAvailable{
                            self.loadMyFriendsPage()
                        }
                    }
                }
            }
        }
        .navigationBarTitle(Text("Friends"), displayMode: .inline)
    }
}

struct FriendsBaseView_Previews: PreviewProvider {
    static var previews: some View {
        FriendsBasicView(searchKeyword: Binding.constant(""), showSearchField: Binding.constant(true)).environmentObject(AppState())
    }
}
