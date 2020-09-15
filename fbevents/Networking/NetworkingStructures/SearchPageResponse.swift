//
//  SearchPageResponse.swift
//  fbevents
//
//  Created by User on 07.08.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import Foundation


extension Networking {
    struct EventSearchPageResponse: Codable{
        struct ViewerEntity: Codable {
            var viewer: TypeaheadSuggesstions
        }
        struct TypeaheadSuggesstions: Codable {
            var eventTypeaheadSuggestions: [SuggestionEntity]
        }
        struct SuggestionEntity: Codable {
            struct TextEntity: Codable {
                var text: String
            }
            struct SuggestionNode: Codable {
                var __typename: String
                var id: String
                var name: String
                var startTimestamp: Int
                var endTimestamp: Int
                var timezone: String
            }
            var suggestionId: String
            var suggestionType: String
            var isUserFacing: Bool
            var parentId: String?
            var deduplicationKey: String
            var suggestionTitle: TextEntity
            var suggestionSubtitle: TextEntity?
            var suggestionNode: SuggestionNode
        }
        var data: ViewerEntity?
        var error: GenericError.ErrorMessage?
    }
}
