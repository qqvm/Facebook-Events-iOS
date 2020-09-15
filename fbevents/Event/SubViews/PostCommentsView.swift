//
//  PostCommentsView.swift
//  fbevents
//
//  Created by User on 09.09.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI
import GRDB


struct PostCommentsView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appState: AppState
    @State var postId: Int
    @State var isFavorite: Bool
    @State var commentsPager = NetworkPager()
    @State var comments = [Comment]()
    
    var body: some View {
        VStack{
            ScrollView{
                HStack{
                    Spacer()
                }
                VStack{
                    PostCommentsRecursiveView(comments: $comments)
                }
            }
        }
        .navigationBarTitle("Post comments", displayMode: .inline)
        .background(self.colorScheme == .light ? Color(red: 0.95, green: 0.95, blue: 0.95) : Color(red: 0.13, green: 0.13, blue: 0.13))
        .onAppear{
            if self.comments.count == 0{
                let lastUpdate = try? self.appState.dbPool!.read({try? Comment.filter(Column("parentId") == self.postId).fetchOne($0)})?.lastUpdate
                if !self.appState.isInternetAvailable || self.appState.isInternetExpensive
                || lastUpdate?.difference(in: .hour, from: Date()) ?? self.appState.settings.reloadIntervalHours < self.appState.settings.reloadIntervalHours{
                    try? self.appState.dbPool!.read{db in
                        if let comments = try? Comment.filter(Column("parentId") == self.postId).fetchAll(db){
                            DispatchQueue.main.async {
                                self.comments.append(contentsOf: comments.sorted(by: {$0.time < $1.time}))
                            }
                        }
                    }
                }
                else{
                    self.loadPostComments()
                }
            }
        }
    }
}

struct PostCommentsRecursiveView: View {
    @State var leftPadding: CGFloat = 0
    var comments: Binding<[Comment]>? = nil
    @State var subComments = [Comment]()

    var body: some View {
        VStack(alignment: .leading){
            ForEach(comments == nil ? subComments : comments!.wrappedValue, id: \.id){(comment: Comment) in
                PostCommentPlateView(leftPadding: self.leftPadding, comment: comment)
            }
        }.padding()
    }
}

struct PostCommentPlateView: View {
    @State var leftPadding: CGFloat = 0
    @State var comment: Comment
    @State var expanded = true
    
    var body: some View {
        VStack(alignment: .leading){
            VStack(alignment: .leading){
                HStack{
                    Text(comment.actor.name)
                    .font(.callout)
                    .fontWeight(.thin)
                    .fixedSize(horizontal: false, vertical: true)
                    if comment.comments.count > 0{
                        Image(systemName: "ellipses.bubble")
                            .foregroundColor(expanded ? .gray : .blue)
                    }
                }
                HStack{
                    Text("\(AppState.getFormattedDate(comment.time, isLong: true, withWeekday: false, withYear: true))")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
                }
                HStack{
                    Text(comment.text)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                }
            }
            .onTapGesture {
                self.expanded.toggle()
            }
            Divider()
            if comment.comments.count > 0 && expanded{
                PostCommentsRecursiveView(leftPadding: self.leftPadding + 20, subComments: comment.comments)
            }
        }.offset(x: leftPadding, y: 0)
        .onAppear{
            if self.leftPadding > 100 {self.leftPadding = 100}
        }
    }
}
