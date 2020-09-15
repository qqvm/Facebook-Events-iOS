//
//  SearchPageResponse.swift
//  fbevents
//
//  Created by User on 07.08.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import Foundation


extension Networking {
    struct PageSearchResponse: Codable, ResponseData{
        struct SerpResponse: Codable {
            var serpResponse: Results?
        }
        struct Results: Codable {
            var results: ResultsEntity
        }
        struct ResultsEntity: Codable {
            struct PageInfo: Codable{
                var startCursor: String?
                var endCursor: String?
                var hasNextPage: Bool
                var hasPreviousPage: Bool?
            }
            struct Edge: Codable {
                struct RelayRenderingStrategy: Codable {
                    struct ViewModel: Codable {
                        struct Profile: Codable {
                            struct ProfilePicture: Codable {
                                var uri: String
                            }
                            var id: String
                            var name: String
                            var profilePicture: ProfilePicture
                            var type: String
                        }
                        var profile: Profile?
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
