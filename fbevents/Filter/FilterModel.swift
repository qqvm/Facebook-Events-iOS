//
//  FilterModel.swift
//  FBEvents
//
//  Created by User on 14.07.2020.
//

import Foundation


struct FilterOptions: Codable, Equatable, Hashable{
    var searchKeyword = ""
    var sortOrder = "Start Time"
    var timeFrame = "All"
    var timeOfTheDay = "Anytime"
    var online = "Any"
    var customFilters = [String]()
    var categories = [String]()
    var selectedTab = 0
    
    static func ==(lhs: FilterOptions, rhs: FilterOptions) -> Bool {
        return (
            lhs.sortOrder == rhs.sortOrder &&
            lhs.timeFrame == rhs.timeFrame &&
            lhs.timeOfTheDay == rhs.timeOfTheDay &&
            lhs.online == rhs.online &&
            lhs.customFilters == rhs.customFilters &&
            lhs.categories == rhs.categories &&
            lhs.searchKeyword == rhs.searchKeyword
        )
    }
    
    mutating func restore(){
        self.searchKeyword = ""
        self.sortOrder = "Start Time"
        self.timeFrame = "All"
        self.timeOfTheDay = "Anytime"
        self.online = "Any"
        //self.selectedTab = 0 // disabled due to better UX
        self.customFilters.removeAll()
        self.categories.removeAll()
    }
}
