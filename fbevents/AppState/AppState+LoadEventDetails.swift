//
//  AppState+LoadEventDetails.swift
//  fbevents
//
//  Created by User on 04.08.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI


extension AppState{
    func loadEventDetails(eventId: Int, withCompletionHandler completionHandler: ((Event) -> Void)? = nil){
        let ntContext =  Networking.EventDetailsVariables.EventDetailsNtContext(usingWhiteNavbar: true, stylesId: "f76946780ad904efe71bf151bec07927", pixelRatio: 4)
        let vars = Networking.EventDetailsVariables(profileImageSize: 280, eventId: String(eventId), scale: "4", ntContext: ntContext, profilePicSizePx: 140, shouldFetchInlineSingleStepConfig: true, profileFacepileImageSize: 210, surface: "PERMALINK")
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        if let varsJson = try? encoder.encode(vars) {
            if let varsParam = String(data: varsJson, encoding: .utf8) {
                var components = URLComponents(url: URL(string: "https://graph.facebook.com/graphql")!, resolvingAgainstBaseURL: false)!
                components.queryItems = [
                    URLQueryItem(name: "doc_id", value: "2947050668677331"),
                    // backup doc_id 2875207235929700 (no auth needed)
                    URLQueryItem(name: "method", value: "post"),
                    URLQueryItem(name: "locale", value: settings.locale),
                    URLQueryItem(name: "pretty", value: "false"),
                    URLQueryItem(name: "format", value: "json"),
                    URLQueryItem(name: "purpose", value: "fetch"),
                    URLQueryItem(name: "variables", value: varsParam),
                    URLQueryItem(name: "fb_api_req_friendly_name", value: "EventPermalinkQuery"),
                    URLQueryItem(name: "fb_api_caller_class", value: "graphservice"),
                    URLQueryItem(name: "fb_api_analytics_tags", value: "[\"GraphServices\"]"),
                    URLQueryItem(name: "server_timestamps", value: "true")
                ]
                networkManager?.postURL(urlComponents: components, withToken: true){(response: Networking.EventDetailsResponse) in
                    if let eventInfo = response.data?.event {
                        var newEvent = Event(
                             id: Int(eventInfo.id)!,
                             name: eventInfo.name,
                             coverPhoto: eventInfo.coverPhoto?.photo.imageLandscape.uri ?? "",
                             startTimestamp: eventInfo.startTimestamp,
                             endTimestamp: eventInfo.endTimestamp,
                             dayTimeSentence: eventInfo.dayTimeSentenceMeetUp,
                             eventPlaceName: eventInfo.eventPlace?.name ?? "",
                             eventPlaceAddress: eventInfo.eventPlace?.address?.singleLineFullAddress ?? "",
                             previewSocialContext: eventInfo.socialContext.text,
                             eventDescription: eventInfo.eventDescription.text,
                             latitude: eventInfo.eventPlace?.location?.latitude ?? 0,
                             longitude: eventInfo.eventPlace?.location?.longitude ?? 0,
                             viewerHasPendingInvite: eventInfo.viewerHasPendingInvite,
                             isChildEvent: eventInfo.isChildEvent,
                             hasChildEvents: eventInfo.hasChildEvents,
                             canViewerPurchaseOnsiteTickets: eventInfo.canViewerPurchaseOnsiteTickets,
                             eventBuyTicketDisplayUrl: eventInfo.eventBuyTicketDisplayUrl,
                             multiDay: Calendar.current.dateComponents([.day], from: AppState.getDate(from: eventInfo.startTimestamp), to: AppState.getDate(from: eventInfo.endTimestamp)).day! > 0,
                             startDate: AppState.getDate(from: eventInfo.startTimestamp),
                             endDate: eventInfo.endTimestamp == 0 ? nil : AppState.getDate(from: eventInfo.endTimestamp),
                             timeOfTheDay: AppState.getTimeOfTheDay(from: eventInfo.startTimestamp),
                             weekDay: AppState.getWeekDay(from: eventInfo.startTimestamp),
                             hosts: eventInfo.eventHosts.edges.compactMap({(edge: Networking.EventDetailsResponse.EventData.EventHosts.HostsNode) -> Actor in
                                Actor(id: Int(edge.node.id)!, type: ActorType(rawValue: edge.node.__typename)!, name: edge.node.name, picture: edge.node.profilePicture.uri)
                             }),
                             eventKind: eventInfo.eventKind,
                             isOnline: eventInfo.isOnline,
                             hasStories: eventInfo.eventStories?.count ?? 0 > 0 ? true : false,
                             onlineUrl: eventInfo.onlineEventSetup?.thirdPartyUrl,
                             goingGuests: eventInfo.totalGoingGuests.count,
                             interestedGuests: eventInfo.totalInterestedGuests.count,
                             goingFriends: eventInfo.goingFriends.count,
                             interestedFriends: eventInfo.interestedFriends.count,
                             maybeFriends: eventInfo.eventMaybesFriendFirst5.edges.map{User(id: Int($0.node.id)!,name: $0.node.name, picture: $0.node.profilePicture.uri, isFriend: true)},
                             memberFriends: eventInfo.eventMembersFriendFirst5.edges.map{User(id: Int($0.node.id)!, name: $0.node.name, picture: $0.node.profilePicture.uri, isFriend: true)},
                             isCanceled: eventInfo.isCanceled,
                             categoryName: eventInfo.eventCategoryData?.label,
                             categoryId: Int(eventInfo.eventCategoryData?.categoryId ?? "")
                        )
                        
                        if let imageUrl = URL(string: newEvent.coverPhoto){
                            newEvent.imageData = try? Data(contentsOf: imageUrl)
                        }
                        
                        if let childs = eventInfo.ticketingChildEvents{
                            newEvent.childEvents = [SimpleChildEvent]()
                            let now = Int(Date().timeIntervalSince1970)
                            let filtered = childs.nodes.filter{
                                $0.currentStartTimestamp >= now
                            }
                            let sortedChilds = filtered.sorted(by: {$0.currentStartTimestamp < $1.currentStartTimestamp})
                            sortedChilds.forEach{
                                newEvent.childEvents?.append(SimpleChildEvent(id: Int($0.id)!, startTimestamp: $0.currentStartTimestamp, endTimestamp: $0.currentEndTimestamp))
                            }
                        }
                        if let parentId = eventInfo.parentEvent?.id{
                            newEvent.parentEventId = Int(parentId)!
                        }
                        
                        newEvent.lastUpdate = Date()
                        
                        if newEvent.exists(dbPool: self.dbPool!){
                            _ = newEvent.updateInDB(dbPool: self.dbPool!)
                        }
                        if newEvent.exists(dbPool: self.cacheDbPool!){
                            _ = newEvent.updateInDB(dbPool: self.cacheDbPool!)
                        }
                        else{
                            _ = newEvent.save(dbPool: self.cacheDbPool!)
                        }

                        if completionHandler != nil{
                            completionHandler!(newEvent)
                        }
                    }
                }
            }
        }
    }
}
