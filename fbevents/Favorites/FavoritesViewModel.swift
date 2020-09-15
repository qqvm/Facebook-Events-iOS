//
//  FavoritesModel.swift
//  fbevents
//
//  Created by User on 21.06.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI


extension FavoritesBasicView{
    func refreshEventsFromDb() {
        DispatchQueue.main.async {
            self.events.removeAll()
            self.loadEventsFromDb()
            self.filterEvents()
            self.sortEvents()
        }
    }
    
    func loadEventsFromDb() {
        do {
            let loadedEvents = self.appState.selectedView == .events ? try appState.cacheDbPool!.read(Event.fetchAll) : try appState.dbPool!.read(Event.fetchAll) // chek to show offline cache
            for event in loadedEvents{
                if (appState.settings.deleteExpired && event.expired) {
                    _ = event.delete(dbPool: self.appState.dbPool!)
                    continue
                }
                else{
                    events.append(event)
                }
            }
        }
        catch{
            self.appState.logger.log(error)
            DispatchQueue.main.async {
                self.appState.errorDescription = error.localizedDescription
                self.appState.showError = true
            }
        }
    }
    
    func sortEvents(){
        switch appState.favoriteFilterOptions.sortOrder{
        case "Relevance":
            break
        case "Start Time":
            events.sort(by: {$0.startDate < $1.startDate})
        case "Popularity":
            events.sort(by: {$0.interestedGuests ?? 0 > $1.interestedGuests ?? 0})
        default:
            break
        }
    }
    
    func filterEvents(){
        events = events.filter{
            self.isFavoriteTab ? !$0.expired : $0.expired
        }.filter{
            self.appState.favoriteFilterOptions.timeOfTheDay == "Anytime" ? true : $0.timeOfTheDay == self.appState.favoriteFilterOptions.timeOfTheDay
        }.filter{
            self.appState.favoriteFilterOptions.timeFrame == "All" ? true :
                $0.timeFrames.contains(self.appState.favoriteFilterOptions.timeFrame)
        }.filter{
            self.appState.favoriteFilterOptions.categories.count == 0 ? true :
                self.appState.favoriteFilterOptions.categories.contains(String($0.categoryName ?? ""))
        }.filter{
            self.appState.favoriteFilterOptions.customFilters.count == 0 ? true : (self.appState.favoriteFilterOptions.customFilters.contains("Friends") && $0.areFriendsInterested)
        }
        
        events = events.filter({el in
            self.appState.favoriteFilterOptions.searchKeyword == "" ? true : (Int(self.appState.favoriteFilterOptions.searchKeyword) ?? -1 == el.id || el.name.lowercased().contains(self.appState.favoriteFilterOptions.searchKeyword.lowercased()))
            }).filter{
                if self.appState.favoriteFilterOptions.online == "Any"{return true}
                else if self.appState.favoriteFilterOptions.online == "Offline" && $0.isOnline != nil{return !$0.isOnline!}
                else if self.appState.favoriteFilterOptions.online == "Online"{return $0.isOnline ?? false}
                else {return false}
            }
    }
    
    func getEventIndex(eventId: Int) -> Int {
        if let index = self.events.firstIndex(where: {$0.id == eventId}){
            return index
        }
        else {
            return -1
        }
    }
}
