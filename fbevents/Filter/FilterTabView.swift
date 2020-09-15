//
//  FilterView.swift
//  fbevents
//
//  Created by User on 21.06.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI

struct FilterTabView: View {
    @EnvironmentObject var appState: AppState
    @Binding var showFilter: Bool
    @Binding var filterOptions: FilterOptions
    
    var body: some View {
        TabView(selection: $filterOptions.selectedTab){
            BaseFilterNavView(showFilter: self.$showFilter, filterOptions: self.$filterOptions){
                ScrollView{
                    HStack{
                        TextField("Keyword or ID", text: self.$filterOptions.searchKeyword){
                            self.showFilter = false
                        }
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.leading)
                        SearchButtonView(action: {
                            self.showFilter = false
                        })
                            .padding(.trailing)
                    }.padding(.top)
                    Group{
                        Text("Sort")
                            .frame(maxWidth: .infinity, alignment: .center)
                        Picker("", selection: self.$filterOptions.sortOrder) {
                            ForEach(FacebookSettings.sortOptions, id: \.self) { el in
                                Text(el)
                            }
                        }
                        .disabled(self.filterOptions.searchKeyword != "")
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                        
                        HStack{
                            Spacer()
                            Text("When").fixedSize()
                            Spacer()
                            Picker(selection: self.$filterOptions.timeFrame, label: HStack{Spacer();Text("When").fixedSize();Spacer()}) {
                                ForEach(FacebookSettings.timeFrameOptions, id: \.self) { el in
                                    Text(el)
                                }
                                }.labelsHidden()
                            .lineLimit(3)
                            .padding(.horizontal)
                            Spacer()
                        }
                        Text("Time of the day")
                            .frame(maxWidth: .infinity, alignment: .center)
                        Picker("", selection: self.$filterOptions.timeOfTheDay) {
                            ForEach(FacebookSettings.timeOfTheDayOptions, id: \.self) { el in
                                Text(el)
                            }
                        }
                        .disabled(self.filterOptions.searchKeyword != "")
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                        .padding(.bottom)
                        Text("Where")
                            .frame(maxWidth: .infinity, alignment: .center)
                        Picker("", selection: self.$filterOptions.online) {
                            ForEach(FacebookSettings.onlineOptions, id: \.self) { el in
                                Text(el)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                    }
                }
            }
                .tabItem {
                    Image(systemName: "dial")
                    Text("Main filters")
                }
                .tag(0)
            BaseFilterNavView(showFilter: self.$showFilter, filterOptions: self.$filterOptions){
                Group{
                    Text("Categoties")
                        .frame(maxWidth: .infinity, alignment: .center)
                    List {
                        ForEach(FacebookSettings.categoryOptions, id: \.self) { item in
                            MultipleSelectionRow(title: item, isSelected: self.filterOptions.categories.contains(item)) {
                                if self.filterOptions.categories.contains(item) {
                                    self.filterOptions.categories.removeAll(where: { $0 == item })
                                }
                                else {
                                    self.filterOptions.categories.append(item)
                                }
                            }
                        }
                    }
                    .listStyle(DefaultListStyle())
                    .frame(width: UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.height - 200, alignment: .center)
                    .border(Color(UIColor.systemGray4))
                    .cornerRadius(3)
                }
            }
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Categories")
                }
                .tag(1)
            BaseFilterNavView(showFilter: self.$showFilter, filterOptions: self.$filterOptions){
                Group{
                    Text("Connected with")
                        .frame(maxWidth: .infinity, alignment: .center)
                    List {
                        ForEach(FacebookSettings.customFilterOptions, id: \.self) { item in
                            MultipleSelectionRow(title: item, isSelected: self.filterOptions.customFilters.contains(item)) {
                                if !self.filterOptions.customFilters.contains(item){
                                    self.filterOptions.customFilters.removeAll()
                                    self.filterOptions.customFilters.append(item)
                                }
                                else{
                                    self.filterOptions.customFilters.removeAll()
                                }
                            }.disabled((self.appState.selectedView == .favorites || !self.appState.isInternetAvailable) && item != "Friends")
                        }
                    }.disabled(self.filterOptions.searchKeyword != "")
                    .listStyle(DefaultListStyle())
                    .frame(width: UIScreen.main.bounds.width - 20, height: 170, alignment: .center)
                    .border(Color(UIColor.systemGray4))
                    .cornerRadius(3)
                }
            }
                .tabItem {
                    Image(systemName: "rectangle.stack.person.crop")
                    Text("Connections")
                }
                .tag(2)
        }
    }
}

struct MultipleSelectionRow: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(self.title)
                if self.isSelected {
                    Spacer()
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                        .padding(.trailing)
                }
            }
        }
    }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        FilterTabView(showFilter: Binding.constant(true), filterOptions: Binding.constant(FilterOptions())).environmentObject(AppState())
    }
}
