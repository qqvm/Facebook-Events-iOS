//
//  FacebookSettings.swift
//  fbevents
//
//  Created by User on 11.09.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import Foundation

struct FacebookSettings{
    static let optionsMapping = [
        "Any":(parameter:"online",value:"null"),
        "Offline":(parameter:"online",value:"null"),
        "Online":(parameter:"online",value:"online"),

        "Relevance":(parameter:"sort",value:"relevance"),
        "Start Time":(parameter:"sort",value:"chrono"),
        "Popularity":(parameter:"sort",value:"popularity"),

        "All":(parameter:"time",value:"null"),
        "Today":(parameter:"time",value:"today"),
        "Tomorrow":(parameter:"time",value:"tomorrow"),
        "This Week":(parameter:"time",value:"this_week"),
        "This Weekend":(parameter:"time",value:"this_weekend"),
        "Next Week":(parameter:"time",value:"next_week"),
        "Next Weekend":(parameter:"time",value:"next_weekend"),

        "Anytime":(parameter:"time_of_the_day",value:"anytime"),
        "Now":(parameter:"time_of_the_day",value:"happening_now"),
        "Daytime":(parameter:"time_of_the_day",value:"daytime"),
        "Evening":(parameter:"time_of_the_day",value:"evening"),
        "Late Night":(parameter:"time_of_the_day",value:"late_night"),

        "Friends":(parameter:"event_custom_filters",value:"friend_events"),
        "Pages and Groups":(parameter:"event_custom_filters",value:"page_and_group_events"),
        "My Places":(parameter:"event_custom_filters",value:"events_at_my_places"),
        "My Groups":(parameter:"event_custom_filters",value:"events_at_my_groups"),

        "Art":(parameter:"event_categories",value:"1116111648515721"),
        "Causes":(parameter:"event_categories",value:"1284277608291920"),
        "Comedy":(parameter:"event_categories",value:"660032617536373"),
        "Crafts":(parameter:"event_categories",value:"258647957895086"),
        "Dance":(parameter:"event_categories",value:"363764800677393"),
        "Drinks":(parameter:"event_categories",value:"412284995786529"),
        "Film":(parameter:"event_categories",value:"392955781081975"),
        "Fitness":(parameter:"event_categories",value:"1138994019544264"),
        "Food":(parameter:"event_categories",value:"370585540007142"),
        "Games":(parameter:"event_categories",value:"1219165261515884"),
        "Gardening":(parameter:"event_categories",value:"1748089758838213"),
        "Health":(parameter:"event_categories",value:"1254988834549294"),
        "Home":(parameter:"event_categories",value:"220618358412161"),
        "Kid Friendly":(parameter:"event_categories",value:"1144692239008422"),
        "Literature":(parameter:"event_categories",value:"432347013823672"),
        "Music":(parameter:"event_categories",value:"1821948261404481"),
        "Networking":(parameter:"event_categories",value:"1915104302042536"),
        "Other":(parameter:"event_categories",value:"359809011100389"),
        "Parties":(parameter:"event_categories",value:"183019258855149"),
        "Religion":(parameter:"event_categories",value:"1763934757268181"),
        "Shopping":(parameter:"event_categories",value:"1759906074034918"),
        "Sports":(parameter:"event_categories",value:"607999416057365"),
        "Theater":(parameter:"event_categories",value:"664694117046626"),
        "Welness":(parameter:"event_categories",value:"1712245629067288")]
    
    static let onlineOptions = Array(FacebookSettings.optionsMapping.filter{$0.value.parameter == "online"}.keys.sorted())
    static let sortOptions = Array(FacebookSettings.optionsMapping.filter{$0.value.parameter == "sort"}.keys.sorted())
    static let timeFrameOptions = Array(FacebookSettings.optionsMapping.filter{$0.value.parameter == "time"}.keys.sorted())
    static let timeOfTheDayOptions = Array(FacebookSettings.optionsMapping.filter{$0.value.parameter == "time_of_the_day"}.keys.sorted())
    static let customFilterOptions = Array(FacebookSettings.optionsMapping.filter{$0.value.parameter == "event_custom_filters"}.keys.sorted())
    static let categoryOptions = Array(FacebookSettings.optionsMapping.filter{$0.value.parameter == "event_categories"}.keys.sorted())
    
    static func getCategoryById(_ id: Int) -> String {
        return FacebookSettings.optionsMapping.filter{$0.value.parameter == "event_categories" && $0.value.value == String(id)}.first?.key ?? ""
    }
}
