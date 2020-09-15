//
//  PostCommentsVariables.swift
//  fbevents
//
//  Created by User on 07.08.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import Foundation


extension Networking {
    struct PostCommentsVariables: Codable{ // camelCase
        struct DisplayCommentsFeedbackContext: Codable{ // snake_case
            struct CommentPermalinkArgs: Codable{ // snake_case
                var commentId: String?
                var replyCommentId: String?
                var filterNonSupporters: String?
            }
            var bumpReason = 0
            var commentExpandMode = 1
            var commentPermalinkArgs = CommentPermalinkArgs()
            var interestingCommentFbids = [String]()
            var isLocationFromSearch = false
            var lastSeenTime: Int?
            var logRankedCommentImpressions = false
            var probabilityToComment = 0
            var storyLocation = 6
            var storyType = 0
        }
        var after: String?
        var before: String?
        var displayCommentsFeedbackContext: String // Escaped DisplayCommentsFeedbackContext
        var displayCommentsContextEnableComment = false
        var displayCommentsContextIsAdPreview = false
        var displayCommentsContextIsAggregatedShare = false
        var displayCommentsContextIsStorySet = false
        var feedLocation = "EVENT"
        var feedbackID: String // Base64 feedback:id
        var feedbackSource = 34
        var first = 2
        var focusCommentID: String?
        var includeNestedComments = true
        //var isInitialFetch = true
        var isComet = false
        var containerIsFeedStory = true
        var containerIsWorkplace = false
        var containerIsLiveStory = false
        var containerIsTahoe = false
        var last: String?
        var scale = 2
        var topLevelViewOption: String?
        var useDefaultActor = true
        var viewOption: String?
        var UFI2CommentsProvider_commentsKey: String?
    }
}
