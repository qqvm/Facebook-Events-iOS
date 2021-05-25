//
//  PageSearchRequestVariables.swift
//  fbevents
//
//  Created by User on 07.08.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import Foundation


extension Networking {
    struct PageSearchRequestVariables: Codable{
        struct Filter: Codable{
            var name: String
            var args: String
        }
        struct Arguments: Codable{
            struct Config: Codable{
                var exactMatch: Bool = false
            }
            struct Experience: Codable{
                var type: String = "PAGES_TAB"
            }
            var callsite: String = "COMET_GLOBAL_SEARCH"
            var config: Config = Config()
            var experience: Experience = Experience()
            var filters: [String] = [String]()
            var text: String // keyword
        }
        var allowStreaming: Bool = false
        var args: Arguments
        var displayCommentsContextEnableComment = false
        var displayCommentsContextIsAdPreview = false
        var displayCommentsContextIsAggregatedShare = false
        var displayCommentsContextIsStorySet = false
        var displayCommentsFeedbackContext: String? = nil
        var feedLocation = "SEARCH"
        var feedbackSource: Int = 23
        var fetchFilters: Bool = false
        var scale: Int = 2
        var streamInitialCount: Int = 0
        var cursor: String?
        var count = 5
        var privacySelectorRenderLocation = "COMET_STREAM"
    }
}
