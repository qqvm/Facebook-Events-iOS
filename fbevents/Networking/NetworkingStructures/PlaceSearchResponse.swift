//
//  SearchPageResponse.swift
//  fbevents
//
//  Created by User on 07.08.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import Foundation


extension Networking {
    struct PlaceSearchResponse: Codable, ResponseData{
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
                        struct PlaceViewModel: Codable {
                            struct PlacesSnippetModel: Codable {
                                struct Location: Codable {
                                    var latitude: Double
                                    var longitude: Double
                                    var address: String
                                }
                                struct Rating: Codable {
                                    var value: Double
                                }
                                var location: Location?
                                var rating: Rating?
                                var price: String?
                            }
                            struct SearchCtaModel: Codable {
                                struct Place: Codable {
                                    var id: String
                                }
                                var place: Place
                            }
                            var title: String
                            var profilePictureUri: String
                            var searchCtaModel: SearchCtaModel
                            var placesSnippetModel: PlacesSnippetModel?
                        }
                        var placeViewModel: PlaceViewModel?
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
