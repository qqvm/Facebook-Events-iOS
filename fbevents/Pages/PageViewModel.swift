//
//  PageViewModel.swift
//  fbevents
//
//  Created by User on 14.08.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI

extension PagesBasicView{
    func refreshPages() {
        if self.isFavoriteTab{
            loadPagesFromDB()
        }
        else{
            if self.searchKeyword != ""{
                self.pagePager.reset()
                self.pages.removeAll()
                self.pagesInFocus.removeAll()
                self.appState.settings.usePagesSearchInsteadOfPlaces ? self.loadPagesSearchPage() : self.loadPlacesSearchPage()
            }
        }
    }
    
    func loadPagesFromDB(){
        do{
            DispatchQueue.main.async {
                self.pages.removeAll()
            }
            let pages = try self.appState.dbPool!.read(Page.fetchAll)
            if self.searchKeyword != ""{
                DispatchQueue.main.async {
                    self.pages.append(contentsOf: pages.filter({$0.name.lowercased().contains((self.searchKeyword).lowercased())}))
                }
            }
            else{
                DispatchQueue.main.async {
                    self.pages.append(contentsOf: pages)
                }
            }
        }
        catch{
            self.appState.logger.log(error)
        }
    }
    
    func loadPagesSearchPage(){
        if !self.pagePager.canProceed {return}
        let requestVars = Networking.PageSearchRequestVariables(args: Networking.PageSearchRequestVariables.Arguments(text: self.searchKeyword/*, filters: [String]()*/), cursor: self.pagePager.endCursor) // Filters could be added later. Currently, I don't think they are needed.

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        if let requestVarsJson = try? encoder.encode(requestVars) {
            if let requestVarsFinal = String(data: requestVarsJson, encoding: .utf8)?.replacingOccurrences(of: "feedback_source", with: "feedbackSource")
                .replacingOccurrences(of: "privacy_selector_render_location", with: "privacySelectorRenderLocation")
                .replacingOccurrences(of: "feed_location", with: "feedLocation")
                .replacingOccurrences(of: "display_comments_feedback_context", with: "displayCommentsFeedbackContext")
                .replacingOccurrences(of: "display_comments_context_is_story_set", with: "displayCommentsContextIsStorySet")
                .replacingOccurrences(of: "display_comments_context_is_aggregated_share", with: "displayCommentsContextIsAggregatedShare")
                .replacingOccurrences(of: "display_comments_context_is_ad_preview", with: "displayCommentsContextIsAdPreview")
                .replacingOccurrences(of: "display_comments_context_enable_comment", with: "displayCommentsContextEnableComment")
            {
                var components = URLComponents(url: URL(string: "https://graph.facebook.com/graphql")!, resolvingAgainstBaseURL: false)!
                components.queryItems = [
                    URLQueryItem(name: "doc_id", value: "4045482902213135"),
                    // backup doc_id 3994449497337419, 3889488077747354, 3286575051390489
                    //URLQueryItem(name: "locale", value: appState.settings.locale),
                    URLQueryItem(name: "variables", value: requestVarsFinal),
                    URLQueryItem(name: "fb_api_req_friendly_name", value: "SearchCometResultsPaginatedResultsQuery"),
                    URLQueryItem(name: "fb_api_caller_class", value: "RelayModern"),
                    URLQueryItem(name: "server_timestamps", value: "true")
                ]
                appState.networkManager?.postURL(urlComponents: components, withToken: true, logNetworkActivity: false){(response: Networking.PageSearchResponse) in
                    if let edges = response.data?.serpResponse?.results.edges{
                        for edge in edges{
                            let page = Page(
                                id: Int(edge.relayRenderingStrategy.viewModel.profile?.id ?? "0")!,
                                name: edge.relayRenderingStrategy.viewModel.profile?.name ?? "No Title",
                                picture: edge.relayRenderingStrategy.viewModel.profile?.profilePicture.uri ?? ""
                            )
                            if page.exists(dbPool: self.appState.dbPool!) && page.picture != ""{
                                _ = page.updateInDB(dbPool: self.appState.dbPool!)
                            }
                            _ = page.exists(dbPool: self.appState.cacheDbPool!) ? page.updateInDB(dbPool: self.appState.cacheDbPool!) : page.save(dbPool: self.appState.cacheDbPool!)
                            DispatchQueue.main.async {
                                if page.id > 0 && !self.pages.contains(where: {$0.id == page.id}){
                                    self.pages.append(page)
                                }
                                
                            }
                        }
                        if let info = response.data?.serpResponse?.results.pageInfo{
                            DispatchQueue.main.async {
                                self.pagePager.endCursor = info.endCursor ?? ""
                                self.pagePager.startCursor = info.startCursor ?? ""
                                self.pagePager.hasNext = info.hasNextPage
                                self.pagePager.hasPrevious = info.hasPreviousPage ?? false
                            }
                        }
                    }
                }
            }
        }
    }
    
    func loadPlacesSearchPage(){ // This method searches over places (logically they are pages too but not all pages are places).
        if !self.pagePager.canProceed {return}
        let requestVars = Networking.PlaceSearchRequestVariables(args: Networking.PlaceSearchRequestVariables.Arguments(text: self.searchKeyword/*, filters: [String]()*/), cursor: self.pagePager.endCursor)  // Filters could be added later. Currently, I don't think they are needed.

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        if let requestVarsJson = try? encoder.encode(requestVars) {
            if let requestVarsFinal = String(data: requestVarsJson, encoding: .utf8)?.replacingOccurrences(of: "feedback_source", with: "feedbackSource")
                .replacingOccurrences(of: "privacy_selector_render_location", with: "privacySelectorRenderLocation")
                .replacingOccurrences(of: "feed_location", with: "feedLocation")
                .replacingOccurrences(of: "display_comments_feedback_context", with: "displayCommentsFeedbackContext")
                .replacingOccurrences(of: "display_comments_context_is_story_set", with: "displayCommentsContextIsStorySet")
                .replacingOccurrences(of: "display_comments_context_is_aggregated_share", with: "displayCommentsContextIsAggregatedShare")
                .replacingOccurrences(of: "display_comments_context_is_ad_preview", with: "displayCommentsContextIsAdPreview")
                .replacingOccurrences(of: "display_comments_context_enable_comment", with: "displayCommentsContextEnableComment")
            {
                var components = URLComponents(url: URL(string: "https://graph.facebook.com/graphql")!, resolvingAgainstBaseURL: false)!
                components.queryItems = [
                    URLQueryItem(name: "doc_id", value: "4045482902213135"),
                    // backup doc_id 3233710406666581, 3549057475175351, 3350139948377577
//                    URLQueryItem(name: "locale", value: appState.settings.locale),
                    URLQueryItem(name: "variables", value: requestVarsFinal),
                    URLQueryItem(name: "fb_api_req_friendly_name", value: "SearchCometResultsPaginatedResultsQuery"),
                    URLQueryItem(name: "fb_api_caller_class", value: "RelayModern"),
                    URLQueryItem(name: "server_timestamps", value: "true")
                ]
                appState.networkManager?.postURL(urlComponents: components, withToken: true, logNetworkActivity: false){(response: Networking.PlaceSearchResponse) in
                    if let edges = response.data?.serpResponse?.results.edges{
                        for edge in edges{
                            let page = Page(
                                id: Int(edge.relayRenderingStrategy.viewModel.placeViewModel?.id.split(separator: "-")[1] ?? "0")!,
                                name: edge.relayRenderingStrategy.viewModel.placeViewModel?.title ?? "No Title",
                                picture: edge.relayRenderingStrategy.viewModel.placeViewModel?.profilePictureUri ?? "",
                                address: edge.relayRenderingStrategy.viewModel.placeViewModel?.placesSnippetModel?.location?.address
                            )
                            if page.id == 0{continue}
                            if page.exists(dbPool: self.appState.dbPool!) && page.picture != ""{
                                _ = page.updateInDB(dbPool: self.appState.dbPool!)
                            }
                            _ = page.exists(dbPool: self.appState.cacheDbPool!) ? page.updateInDB(dbPool: self.appState.cacheDbPool!) : page.save(dbPool: self.appState.cacheDbPool!)
                            DispatchQueue.main.async {
                                if page.id > 0 && !self.pages.contains(where: {$0.id == page.id}){
                                    self.pages.append(page)
                                }
                            }
                        }
                        if let info = response.data?.serpResponse?.results.pageInfo{
                            DispatchQueue.main.async {
                                self.pagePager.endCursor = info.endCursor ?? ""
                                self.pagePager.startCursor = info.startCursor ?? ""
                                self.pagePager.hasNext = info.hasNextPage
                                self.pagePager.hasPrevious = info.hasPreviousPage ?? false
                            }
                        }
                    }
                }
            }
        }
    }
}

extension PageEventsView{
    func loadEventsFromCache(){
        do{
            self.pageEvents.removeAll()
            let events = try self.appState.cacheDbPool!.read(Event.fetchAll)
            self.pageEvents.append(contentsOf: events.filter({($0.hosts.map{$0.id == self.page.id}).contains(true)}))
        }
        catch{
            self.appState.logger.log(error)
        }
    }
    
    func loadPageUpcomingEventsPage(completion: (()->())? = nil){
        if !self.upcomingEventPager.canProceed {return}
        let requestVars = Networking.PageEventsVariables(pageID: String(self.page.id), cursor: self.upcomingEventPager.endCursor)
        //self.appState.logger.log("upcoming cursor:", self.upcomingEventPager.endCursor)
        let encoder = JSONEncoder()
        if let requestVarsJson = try? encoder.encode(requestVars) {
            if let requestVarsFinal = String(data: requestVarsJson, encoding: .utf8) {
                var components = URLComponents(url: URL(string: "https://graph.facebook.com/graphql")!, resolvingAgainstBaseURL: false)!
                components.queryItems = [
                    URLQueryItem(name: "doc_id", value: "2982976778460523"),
                    // backup doc_id 2956504877730672, may work only for first page
                    URLQueryItem(name: "locale", value: appState.settings.locale),
                    URLQueryItem(name: "variables", value: requestVarsFinal),
                    URLQueryItem(name: "fb_api_req_friendly_name", value: "PageEventsTabUpcomingEventsCardRendererQuery"),
                    URLQueryItem(name: "fb_api_caller_class", value: "RelayModern"),
                    URLQueryItem(name: "server_timestamps", value: "true")
                ]
                appState.networkManager?.postURL(urlComponents: components, withToken: true){(response: Networking.PageEventsResponse) in
                    if let edges = response.data?.page?.upcomingEvents?.edges{
                        for edge in edges{
                            let event = SimpleEvent(
                                id: Int(edge.node.id)!,
                                name: edge.node.name,
                                coverPhoto: "", dayTimeSentence: edge.node.shortTimeLabel
                            )
                            DispatchQueue.main.async {
                                if !self.pageEvents.contains(where: {$0.id == event.id}){
                                    self.pageEvents.append(event)
                                }
                            }
                        }
                        if let info = response.data?.page?.upcomingEvents?.pageInfo{
                            DispatchQueue.main.async {
                                self.upcomingEventPager.endCursor = info.endCursor ?? ""
                                self.upcomingEventPager.startCursor = info.startCursor ?? ""
                                self.upcomingEventPager.hasNext = info.hasNextPage
                                self.upcomingEventPager.hasPrevious = info.hasPreviousPage ?? false
                            }
                        }
                    }
                }
            }
        }
    }
    
    func loadPageRecurringEventsPage(completion: (()->())? = nil){
        if !self.recurringEventPager.canProceed {return}
        let requestVars = Networking.PageEventsVariables(pageID: String(self.page.id), cursor: self.recurringEventPager.endCursor)
        //self.appState.logger.log("recurring cursor:", self.recurringEventPager.endCursor)
        let encoder = JSONEncoder()
        if let requestVarsJson = try? encoder.encode(requestVars) {
            if let requestVarsFinal = String(data: requestVarsJson, encoding: .utf8) {
                var components = URLComponents(url: URL(string: "https://graph.facebook.com/graphql")!, resolvingAgainstBaseURL: false)!
                components.queryItems = [
                    URLQueryItem(name: "doc_id", value: "3174872339242074"),
                    //backup doc_id ??
                    URLQueryItem(name: "locale", value: appState.settings.locale),
                    URLQueryItem(name: "variables", value: requestVarsFinal),
                    URLQueryItem(name: "fb_api_req_friendly_name", value: "PageEventsTabUpcomingEventsCardRendererQuery"),
                    URLQueryItem(name: "fb_api_caller_class", value: "RelayModern"),
                    URLQueryItem(name: "server_timestamps", value: "true")
                ]
                appState.networkManager?.postURL(urlComponents: components, withToken: true){(response: Networking.PageEventsResponse) in
                    if let edges = response.data?.page?.upcomingRecurringEvents?.edges{
                        for edge in edges{
                            let event = SimpleEvent(
                                id: Int(edge.node.id)!,
                                name: edge.node.name,
                                coverPhoto: "", dayTimeSentence: edge.node.timeContext
                            )
                            DispatchQueue.main.async {
                                if !self.pageEvents.contains(where: {$0.id == event.id}){
                                    self.pageEvents.append(event)
                                }
                            }
                        }
                        if let info = response.data?.page?.upcomingRecurringEvents?.pageInfo{
                            DispatchQueue.main.async {
                                self.recurringEventPager.endCursor = info.endCursor ?? ""
                                self.recurringEventPager.startCursor = info.startCursor ?? ""
                                self.recurringEventPager.hasNext = info.hasNextPage
                                self.recurringEventPager.hasPrevious = info.hasPreviousPage ?? false
                            }
                        }
                    }
                }
            }
        }
    }
}
