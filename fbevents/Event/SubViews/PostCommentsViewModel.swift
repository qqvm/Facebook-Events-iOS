//
//  PostCommentsViewModel.swift
//  fbevents
//
//  Created by User on 09.09.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI

extension PostCommentsView{    
    func getCommentsFromJson(_ jsonComments: Networking.PostCommentsResponse.DisplayComments, parentId: Int, parentType: String, isFavorite: Bool) -> [Comment]{
        var comments = [Comment]()
        for edge in jsonComments.edges{
            var comment = Comment(
                id: appState.getIdFromFbString(edge.node.id),
                parentId: parentId,
                parentType: parentType,
                actor: Actor(id: Int(edge.node.author.id)!, type: ActorType(rawValue: edge.node.author.__typename)!, name: edge.node.author.name, picture: edge.node.author.profilePictureDepth0.uri),
                text: edge.node.body?.text ?? "No comment",
                time: edge.node.createdTime, lastUpdate: Date()
            )
            if let displayComments = edge.node.feedback.displayComments{
                comment.comments.append(contentsOf: getCommentsFromJson(displayComments, parentId: comment.id, parentType: "Comment", isFavorite: isFavorite))
            }
            if isFavorite && parentType == "Post"{ // No need to save subcomments because they already inside parent comment.
                if comment.exists(dbPool: self.appState.dbPool!){
                    _ = comment.updateInDB(dbPool: self.appState.dbPool!)
                }
                else{
                    _ = comment.save(dbPool: self.appState.dbPool!)
                }
            }
            comments.append(comment)
        }
        return comments.sorted(by: {$0.time < $1.time})
    }
    
    func loadPostComments(){
        if !commentsPager.canProceed {return}
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let feedbackContext = Networking.PostCommentsVariables.DisplayCommentsFeedbackContext()
        let vars = Networking.PostCommentsVariables(after: commentsPager.endCursor, displayCommentsFeedbackContext: String(data: try! encoder.encode(feedbackContext), encoding: .utf8)!, feedbackID: "feedback:\(postId)".data(using: .utf8)!.base64EncodedString())
        encoder.keyEncodingStrategy = .useDefaultKeys
        if let requestVars = try? encoder.encode(vars) {
            if let suggestionContext = String(data: requestVars, encoding: .utf8) {
                var components = URLComponents(url: URL(string: "https://graph.facebook.com/graphql")!, resolvingAgainstBaseURL: false)!
                components.queryItems = [
                    URLQueryItem(name: "doc_id", value: "3189628074481317"),
                    URLQueryItem(name: "locale", value: appState.settings.locale),
                    URLQueryItem(name: "variables", value: suggestionContext),
                    URLQueryItem(name: "fb_api_req_friendly_name", value: "UFI2CommentsProviderPaginationQuery"),
                    URLQueryItem(name: "fb_api_caller_class", value: "RelayModern"),
                    URLQueryItem(name: "server_timestamps", value: "true")
                ]
                appState.networkManager?.postURL(urlComponents: components, withToken: true){(response: Networking.PostCommentsResponse) in
                    if let input = response.data?.feedback?.displayComments{
                        if let info = response.data?.feedback?.displayComments?.pageInfo{
                            DispatchQueue.main.async{
                                self.commentsPager.endCursor = info.endCursor ?? ""
                                self.commentsPager.startCursor = info.startCursor ?? ""
                                self.commentsPager.hasNext = info.hasNextPage
                                self.commentsPager.hasPrevious = info.hasPreviousPage ?? false
                            }
                        }
                        let comments = self.getCommentsFromJson(input, parentId: self.postId, parentType: "Post", isFavorite: self.isFavorite)
                        DispatchQueue.main.async {
                            comments.forEach{
                                if !self.comments.contains($0){self.comments.append($0)}
                            }
                        }
                        if self.commentsPager.canProceed && input.afterCount != input.beforeCount{
                            self.loadPostComments()
                        }
                        else{
                            DispatchQueue.main.async {
                                self.comments.sort(by: {$0.time < $1.time})
                            }
                        }
                    }
                    
                }
            }
        }
    }
}
