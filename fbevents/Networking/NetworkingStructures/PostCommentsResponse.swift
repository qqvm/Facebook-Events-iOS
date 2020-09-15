//
//  PostCommentsResponse.swift
//  fbevents
//
//  Created by User on 07.08.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import Foundation


extension Networking {
    struct PostCommentsResponse: Codable, ResponseData{
        struct DataEntity: Codable {
            var feedback: FeedbackEntity?
        }
        struct FeedbackEntity: Codable {
            var id: String // Base64 feedback:id
            var displayComments: DisplayComments?
        }
        struct PageInfo: Codable{
            var startCursor: String?
            var endCursor: String?
            var hasNextPage: Bool
            var hasPreviousPage: Bool?
        }
        struct DisplayComments: Codable {
            struct Edge: Codable {
                struct Node: Codable {
                    struct Text: Codable {
                        var text: String
                    }
                    struct ParentFeedback: Codable {
                        var id: String // Bse64
                    }
                    struct Feedback: Codable{
                        struct CommentCount: Codable {
                            var totalCount: Int
                        }
                        struct ToplevelCommentCount: Codable {
                            var count: Int
                        }
                        var id: String // Bse64
                        var commentCount: CommentCount?
                        var toplevelCommentCount: ToplevelCommentCount?
                        var displayComments: DisplayComments?
                    }
                    struct Author: Codable {
                        struct Picture: Codable {
                            var uri: String
                        }
                        var __typename: String
                        var id: String
                        var name: String
                        var profilePictureDepth0: Picture
                    }
                    var id: String // Bse64
                    var createdTime: Int
                    var author: Author
                    var parentFeedback: ParentFeedback
                    var feedback: Feedback
                    var url: String
                    var body: Text?
                    var isMarkdownEnabled: Bool
                }
                var node: Node
                var cursor: String
            }
            var afterCount: Int
            var beforeCount: Int
            var count: Int
            var edges: [Edge]
            var commentOrder: String // TOPLEVEL is descending order
            var pageInfo: PageInfo?
        }
        var data: DataEntity?
        var error: GenericError.ErrorMessage?
        var errors: [GenericError.ErrorMessage]?
    }
}
