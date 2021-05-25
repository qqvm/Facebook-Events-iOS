//
//  EventChildsView.swift
//  fbevents
//
//  Created by User on 05.08.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI
import GRDB


struct EventPostsView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appState: AppState
    @State var eventId: Int
    @State var isEventFavorite: Bool
    @State var showOnlyPinned = false
    @State var posts = [Post]()
    
    var body: some View {
        VStack{
            VStack{
                List{
                    if showOnlyPinned ? posts.filter{$0.pinned}.count == 0 : posts.count == 0{
                        EmptySection()
                    }
                    else{
                        Section{
                            ForEach(showOnlyPinned ? posts.filter{$0.pinned} : posts, id: \.id){(post: Post) in
                                NavigationLink(destination: PostCommentsView(postId: post.id, isFavorite: self.isEventFavorite)){
                                    VStack{
                                        HStack{
                                            if post.pinned{
                                                Image(systemName: "pin")
                                            }
                                            Text(post.actors.map{$0.name}.joined(separator: ", "))
                                            .font(.headline)
                                            .fontWeight(.thin)
                                            .fixedSize(horizontal: false, vertical: true)
                                        }.padding(.top)
                                        HStack{
                                            Text("\(AppState.getFormattedDate(post.time, isLong: true, withWeekday: false, withYear: true))")
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                            .fixedSize(horizontal: false, vertical: true)
                                        }
                                        VStack{
                                            TextView(text: post.text)
                                                .frame(width: UIScreen.main.bounds.width - 40, height: self.appState.getAproxTextHeight(post.text), alignment: .leading)
                                            .padding(.trailing)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }.listStyle(DefaultListStyle())
            }
        }
        .onAppear{
            if self.posts.count == 0{
                let lastUpdate = try? self.appState.dbPool!.read({try? Post.filter(Column("parentId") == self.eventId).fetchOne($0)})?.lastUpdate
                if !self.appState.isInternetAvailable || self.appState.isInternetExpensive
                || lastUpdate?.difference(in: .hour, from: Date()) ?? self.appState.settings.reloadIntervalHours < self.appState.settings.reloadIntervalHours{
                    try? self.appState.dbPool!.read{db in
                        if let posts = try? Post.filter(Column("parentId") == self.eventId).fetchAll(db){
                            DispatchQueue.main.async {
                                self.posts.append(contentsOf: posts.sorted(by: {$0.pinned && !$1.pinned}))
                            }
                        }
                    }
                }
                else{
                    self.loadEventPosts()
                }
            }
        }
        .background(self.colorScheme == .light ? Color(red: 0.95, green: 0.95, blue: 0.95) : Color(red: 0.13, green: 0.13, blue: 0.13))
        .navigationBarTitle("Recent posts", displayMode: .inline)
        .navigationBarItems(trailing:
            Button(action: {self.showOnlyPinned.toggle()}, label: {
                Image(systemName: self.showOnlyPinned ? "pin.fill" : "pin")
            })
            .padding(.trailing)
            .disabled(posts.count == 0))
    }
}
