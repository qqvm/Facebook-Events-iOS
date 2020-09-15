//
//  SearchPageResponse.swift
//  fbevents
//
//  Created by User on 07.08.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import Foundation


extension Networking {
    struct EventSearchByKeywordResponse: Codable, ResponseData{
        struct SerpResponse: Codable {
            var serpResponse: Results?
        }
        struct Results: Codable {
            var results: ResultsEntity
        }
        struct ResultsEntity: Codable {
            struct PageInfo: Codable{
                var startCursor: String?
                var endCursor: String
                var hasNextPage: Bool
                var hasPreviousPage: Bool?
            }
            struct Edge: Codable {
                struct RelayRenderingStrategy: Codable {
                    struct ViewModel: Codable {
                        struct Profile: Codable {
                            struct Picture: Codable {
                                var uri: String
                            }
                            var id: String
                            var name: String
                            var profilePicture: Picture
                        }
                        struct ProminentSnippetConfig: Codable {
                            struct TextWithEntities: Codable {
                                var text: String
                            }
                            var textWithEntities: TextWithEntities
                        }
                        var profile: Profile?
                        var prominentSnippetConfig: ProminentSnippetConfig?
                    }
                    var viewModel: ViewModel
                }
                var relayRenderingStrategy: RelayRenderingStrategy
            }
            var edges: [Edge]
            var pageInfo: PageInfo?
        }
        var data: SerpResponse?
        var error: GenericError.ErrorMessage?
        var errors: [GenericError.ErrorMessage]?
    }
}
