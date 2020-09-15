//
//  EventSearchViewModel.swift
//  fbappState.searchEvents
//
//  Created by User on 21.06.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI
import Network
import SwiftDate


extension EventSearchView {
    func loadEventDiscoverPage(){
        if !self.appState.searchPager.canProceed {return}
        var contextData = Networking.EventSearchPageSuggestionContext.SuggestionData(
            timezone: appState.settings.timezone,
            time: FacebookSettings.optionsMapping[appState.settings.filterOptions.timeFrame]!.value == "null" ? nil : FacebookSettings.optionsMapping[appState.settings.filterOptions.timeFrame]!.value,
            timeOfTheDay: FacebookSettings.optionsMapping[appState.settings.filterOptions.timeOfTheDay]!.value,
            sort: FacebookSettings.optionsMapping[appState.settings.filterOptions.sortOrder]!.value,
            eventCustomFilters: appState.settings.filterOptions.customFilters.map{String(FacebookSettings.optionsMapping[$0]!.value)},
            eventCategories: appState.settings.filterOptions.categories.map{Int(FacebookSettings.optionsMapping[$0]!.value)!}
        )
        if self.appState.settings.filterOptions.online == "Online"{
            contextData.eventFlags = [String](arrayLiteral: "online")
        }
        if appState.settings.useCoordinates{
            contextData.latLon = Networking.EventSearchPageSuggestionContext.SuggestionData.LatLon(latitude: appState.settings.cityLat, longitude: appState.settings.cityLon)
        }
        else{
            contextData.city = "default_\(appState.settings.cityId)"
        }
        let context = Networking.EventSearchPageSuggestionContext(suggestionContext: contextData,
                                        eventsConnectionFirst: 10,
                                        eventsConnectionAtStreamUseCustomizedBatch: false,
                                        eventsConnectionAfterCursor: self.appState.searchPager.endCursor)
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        if let suggestionJson = try? encoder.encode(context) {
            if let suggestionContext = String(data: suggestionJson, encoding: .utf8) {
                var components = URLComponents(url: URL(string: "https://graph.facebook.com/graphql")!, resolvingAgainstBaseURL: false)!
                components.queryItems = [
                    URLQueryItem(name: "doc_id", value: "3228095340582257"),
                    // backup doc_id: 3837985036242754
                    URLQueryItem(name: "method", value: "post"),
                    URLQueryItem(name: "locale", value: appState.settings.locale),
                    URLQueryItem(name: "pretty", value: "false"),
                    URLQueryItem(name: "format", value: "json"),
                    URLQueryItem(name: "purpose", value: "fetch"),
                    URLQueryItem(name: "variables", value: suggestionContext),
                    URLQueryItem(name: "fb_api_req_friendly_name", value: "SocalEventsSetSearchQuery"),
                    URLQueryItem(name: "fb_api_caller_class", value: "graphservice"),
                    URLQueryItem(name: "fb_api_analytics_tags", value: "[\"GraphServices\",\"At_Connection\"]"),
                    URLQueryItem(name: "server_timestamps", value: "true")
                ]
                appState.networkManager?.postURL(urlComponents: components, withToken: true){(response: Networking.EventSearchPageResponse) in
                    if let edges = response.data?.viewer.suggestedEvents.events.edges {
                        for edge in edges{
                            if self.appState.settings.enableBanning{
                                if self.appState.settings.bannedWords.map({edge.node.name.contains($0)}).contains(true) || self.appState.settings.bannedWords.map({edge.node.eventDescription.text.contains($0)}).contains(true){
                                    continue
                                }
                            }
                            let newEvent = Event(
                                id: Int(edge.node.id)!,
                                name: edge.node.name,
                                coverPhoto: edge.node.coverPhoto?.photo.image.uri ?? "",
                                startTimestamp: edge.node.startTimestamp,
                                endTimestamp: edge.node.endTimestamp,
                                dayTimeSentence: edge.node.dayTimeSentence,
                                eventPlaceName: edge.node.eventPlace.name,
                                eventPlaceAddress: edge.node.location.reverseGeocode.state == nil || edge.node.location.reverseGeocode.state == "" ? "\(edge.node.location.reverseGeocode.address), \(edge.node.location.reverseGeocode.city)" : "\(edge.node.location.reverseGeocode.address), \(edge.node.location.reverseGeocode.city), \(edge.node.location.reverseGeocode.state!)",
                                previewSocialContext: edge.node.previewSocialContext.textWithEntities.text,
                                eventDescription: edge.node.eventDescription.text,
                                latitude: edge.node.location.latitude,
                                longitude: edge.node.location.longitude,
                                viewerHasPendingInvite: edge.node.viewerHasPendingInvite,
                                isChildEvent: edge.node.isChildEvent,
                                hasChildEvents: edge.node.hasChildEvents,
                                canViewerPurchaseOnsiteTickets: edge.node.canViewerPurchaseOnsiteTickets,
                                eventBuyTicketDisplayUrl: edge.node.eventBuyTicketDisplayUrl,
                                multiDay: Calendar.current.dateComponents([.day], from: AppState.getDate(from: edge.node.startTimestamp), to: AppState.getDate(from: edge.node.endTimestamp)).day! > 0,
                                startDate: AppState.getDate(from: edge.node.startTimestamp),
                                endDate: edge.node.endTimestamp == 0 ? nil : AppState.getDate(from: edge.node.endTimestamp),
                                timeOfTheDay: AppState.getTimeOfTheDay(from: edge.node.startTimestamp),
                                weekDay: AppState.getWeekDay(from: edge.node.startTimestamp)
                            )
                            if !newEvent.exists(dbPool: self.appState.cacheDbPool!){
                                _ = newEvent.save(dbPool: self.appState.cacheDbPool!)
                            }
                            DispatchQueue.main.async {
                                let index = self.getEventIndex(eventId: newEvent.id)
                                if index == -1 {
                                    self.appState.searchEvents.append(newEvent)
                                }
                                else{
                                    self.appState.searchEvents[index] = newEvent
                                }
                            }
                        }
                        if let info = response.data?.viewer.suggestedEvents.events.pageInfo{
                            DispatchQueue.main.async {
                                self.appState.searchPager.endCursor = info.endCursor ?? ""
                                self.appState.searchPager.startCursor = info.startCursor ?? ""
                                self.appState.searchPager.hasNext = info.hasNextPage
                                self.appState.searchPager.hasPrevious = info.hasPreviousPage
                            }
                            //self.sortEvents()
                        }
                    }
                }
            }
        }
    }
    
    func loadEventSearchPageByKeyword(){
        if let id = Int(self.appState.settings.filterOptions.searchKeyword){
            if self.appState.settings.filterOptions.searchKeyword.count > 4{
                self.appState.loadEventDetails(eventId: id)
                return
            }
        }
        if !self.appState.searchPager.canProceed {return}
        var filters = [String]()
        if self.appState.settings.cityId != 0{
            filters.append("{\"name\":\"filter_events_location\",\"args\":\"\(self.appState.settings.cityId)\"}")
        }
        if self.appState.settings.filterOptions.timeFrame != "All"{
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            if self.appState.settings.filterOptions.timeFrame == "Today"{
                filters.append("{\"name\":\"filter_events_date\",\"args\":\"\(formatter.string(from: Date()))\"}")
            }
            else if self.appState.settings.filterOptions.timeFrame == "Tomorrow"{
                filters.append("{\"name\":\"filter_events_date\",\"args\":\"\(formatter.string(from: Date()))\"}")
            }
            else{
                var start: Date? = nil
                var end: Date? = nil
                if self.appState.settings.filterOptions.timeFrame == "This Week"{
                    start = Date()
                    if Date().weekday != 7{
                        end = start?.nextWeekday(.sunday)
                    }
                }
                else if self.appState.settings.filterOptions.timeFrame == "This Weekend"{
                    if Date().weekday == 6{
                        start = Date()
                        end = start?.nextWeekday(.sunday)
                    }
                    else if Date().weekday == 7{
                        start = Date().nextWeekday(.saturday)
                    }
                    else{
                        start = Date().nextWeekday(.saturday)
                        end = start?.nextWeekday(.sunday)
                    }
                }
                else if self.appState.settings.filterOptions.timeFrame == "Next Week"{
                    start = Date().nextWeekday(.monday)
                    end = start?.nextWeekday(.sunday)
                }
                else if self.appState.settings.filterOptions.timeFrame == "Next Weekend"{
                    start = Date().nextWeekday(.monday).nextWeekday(.saturday)
                    end = start?.nextWeekday(.sunday)
                }
                if end != nil{
                    filters.append("{\"name\":\"filter_events_date\",\"args\":\"\(formatter.string(from: start!))~\(formatter.string(from: end!))\"}")
                }
                else{
                    filters.append("{\"name\":\"filter_events_date\",\"args\":\"\(formatter.string(from: start!))\"}")
                }
            }
        }
        if self.appState.settings.filterOptions.online == "Online"{
            filters.append("{\"name\":\"filter_events_online\",\"args\":\"\"}")
        }
        if self.appState.settings.filterOptions.categories.count > 0{
            for cat in self.appState.settings.filterOptions.categories{
                if cat != "Kid Friendly"{
                    filters.append("{\"name\":\"filter_events_category\",\"args\":\"\(FacebookSettings.optionsMapping[cat]!.value)\"}")
                }
                else{
                    filters.append("{\"name\":\"filter_events_kids_friendly\",\"args\":\"\"}")
                }
            }
        }
        let args = Networking.EventSearchByKeywordRequestArguments.Arguments(filters: filters, text: self.appState.settings.filterOptions.searchKeyword)
        let requestVars = Networking.EventSearchByKeywordRequestArguments(args: args, cursor: self.appState.searchPager.endCursor)
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        if let requestVarsJson = try? encoder.encode(requestVars) {
            if let requestVarsFinal = String(data: requestVarsJson, encoding: .utf8)?.replacingOccurrences(of: "feedback_source", with: "feedbackSource") {
                var components = URLComponents(url: URL(string: "https://graph.facebook.com/graphql")!, resolvingAgainstBaseURL: false)!
                components.queryItems = [
                    URLQueryItem(name: "doc_id", value: "4390892870951634"),
                    // backup doc_id 3379715488726919
                    // also, a bit different 3325573300819142
                    URLQueryItem(name: "locale", value: appState.settings.locale),
                    URLQueryItem(name: "variables", value: requestVarsFinal),
                    URLQueryItem(name: "fb_api_req_friendly_name", value: "CometSearchResultsInitialResultsQuery"),
                    URLQueryItem(name: "fb_api_caller_class", value: "RelayModern"),
                    URLQueryItem(name: "server_timestamps", value: "true")
                ]
                appState.networkManager?.postURL(urlComponents: components, withToken: true){(response: Networking.EventSearchByKeywordResponse) in
                    if let edges = response.data?.serpResponse?.results.edges{
                        for edge in edges{
                            if let profile = edge.relayRenderingStrategy.viewModel.profile{
                                let event = SimpleEvent(
                                    id: Int(profile.id)!,
                                    name: profile.name,
                                    coverPhoto: profile.profilePicture.uri,
                                    dayTimeSentence: edge.relayRenderingStrategy.viewModel.prominentSnippetConfig?.textWithEntities.text ?? "No information"
                                )
                                DispatchQueue.main.async {
                                    self.appState.searchEvents.append(event)
                                }
                            }
                        }
                        if let info = response.data?.serpResponse?.results.pageInfo{
                            DispatchQueue.main.async {
                                self.appState.searchPager.endCursor = info.endCursor
                                self.appState.searchPager.startCursor = info.startCursor ?? ""
                                self.appState.searchPager.hasNext = info.hasNextPage
                                self.appState.searchPager.hasPrevious = info.hasPreviousPage ?? false
                            }
                            //self.sortEvents()
                        }
                    }
                }
            }
        }
    }
    
    func loadNonSearchEventsPage(){
        if !self.nonSearchPager.canProceed {return}
        var variables = Networking.CalendarVariables(cursor: self.nonSearchPager.endCursor)
        if self.selectedTab == 2{
            variables.id = "\(self.appState.settings.userId)"
        }
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        if let variablesJson = try? encoder.encode(variables) {
            if let finalVariablesJson = String(data: variablesJson, encoding: .utf8) {
                var components = URLComponents(url: URL(string: "https://graph.facebook.com/graphql")!, resolvingAgainstBaseURL: false)!
                components.queryItems = [
                    URLQueryItem(name: "doc_id", value: self.selectedTab == 1 ? "4345654755459664" : "2976546702462506"),
                    URLQueryItem(name: "locale", value: appState.settings.locale),
                    URLQueryItem(name: "variables", value: finalVariablesJson),
                    URLQueryItem(name: "fb_api_req_friendly_name", value: self.selectedTab == 1 ? "LocalCalendarInvitesRootQuery" : "LocalPastEventsRootQuery"),
                    URLQueryItem(name: "fb_api_caller_class", value: "RelayModern"),
                    URLQueryItem(name: "server_timestamps", value: "true")
                ]
                appState.networkManager?.postURL(urlComponents: components, withToken: true, dataPreprocessHadnler: {(data: Data) in
                    return (String(data: data, encoding: .utf8)?.split(separator: "\r\n").first ?? "").data(using: .utf8)!
                }){(response: Networking.CalendarPageResponse) in
                    if let edges = response.data?.viewer.actor.allEvents?.edges{
                        for edge in edges{

                            let newEvent = SimpleEvent(
                                id: Int(edge.node.id)!,
                                name: edge.node.name,
                                coverPhoto: edge.node.coverMediaRenderer.coverPhoto?.photo.image.uri ?? "",
                                dayTimeSentence: AppState.getFormattedDate(edge.node.utcStartTimestamp, isLong: true, withYear: true)
                            )
                            DispatchQueue.main.async {
                                if !self.nonSearchEvents.contains(where: {$0.id == newEvent.id}){
                                    self.nonSearchEvents.append(newEvent)
                                }
                            }
                        }
                        if let info = response.data?.viewer.actor.allEvents?.pageInfo{
                            DispatchQueue.main.async {
                                self.nonSearchPager.endCursor = info.endCursor ?? ""
                                self.nonSearchPager.startCursor = info.startCursor ?? ""
                                self.nonSearchPager.hasNext = info.hasNextPage
                                self.nonSearchPager.hasPrevious = info.hasPreviousPage ?? false
                            }
                            //self.sortEvents()
                        }
                    }
                }
            }
        }
    }
    
    func refreshEvents(){
        DispatchQueue.main.async {
            switch self.selectedTab {
            case 0:
                self.appState.searchEvents.removeAll()
                self.appState.searchPager.reset()
                self.inFocus.removeAll()
                if self.appState.settings.token != "" && self.appState.settings.filterOptions.searchKeyword == ""{
                    self.loadEventDiscoverPage()
                }
                else if self.appState.settings.token != "" && self.appState.settings.filterOptions.searchKeyword != ""{
                    self.loadEventSearchPageByKeyword()
                }
            case 1,2:
                self.nonSearchEvents.removeAll()
                self.nonSearchPager.reset()
                if self.appState.settings.token != ""{
                    self.loadNonSearchEventsPage()
                }
            default:
                break
            }
        }
    }
    
    func getEventIndex(eventId: Int) -> Int {
        var index: Int? = nil
        switch self.selectedTab {
        case 0:
            index = self.appState.searchEvents.firstIndex(where: {$0.id == eventId})
        case 1,2:
            index = self.nonSearchEvents.firstIndex(where: {$0.id == eventId})
        default:
            break
        }
        if let index = index{
            return index
        }
        else {
            return -1
        }
    }
}
