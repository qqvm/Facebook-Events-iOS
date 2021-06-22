//
//  CitySearchView.swift
//  fbevents
//
//  Created by User on 27.06.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI
import CoreLocation


struct CitySearchBasicView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var currentLocation = CurrentLocation()
    @State private var showSheet = false
    @State var searchCityName = ""
    @State private var options = [Networking.CityResponse.Result]()
    
    func generateActionSheet(options: [String]) -> ActionSheet {
        let buttons = options.map {option in
            Alert.Button.default(Text(option), action: {
                self.saveSelection(option)
            })
        }
        return ActionSheet(title: Text("Select city from list:"),
                           message: Text("Usually, first variant is good enough.\n Pay attention that selecting unknown variant\nmay lead to no results."),
                           buttons: buttons + [Alert.Button.cancel()])
    }
    
    fileprivate func saveSelection(_ selection: String) {
        if true {
            if selection != ""{
                let cityData = self.options.first{$0.name == selection}
                if cityData != nil{
                    self.appState.settings.cityId =  Int(cityData!.id)!
                    self.appState.settings.cityName = cityData!.name
                    self.appState.settings.cityLat = Double(String(format: "%.4f", cityData!.location.latitude))!
                    self.appState.settings.cityLon = Double(String(format: "%.4f", cityData!.location.longitude))!
                    self.searchCityName = cityData!.name
                    self.appState.settings.filterChanged = true
                    self.appState.settings.saveAll()
                }
            }
        }
    }
    
    var body: some View {
        HStack{
            TextField("", text: $searchCityName){
                self.tryCitySearch(){(results: [Networking.CityResponse.Result]) in
                    if results.count > 0{
                        self.options.removeAll()
                        self.options.append(contentsOf: results)
                        self.showSheet.toggle()
                    }
                }
            }
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .border(self.appState.settings.cityName != "" ? Color(UIColor.systemGray3) : Color(.red))
            .cornerRadius(3)
            GPSButtonView(action: {
                self.currentLocation.startLocationManager()
            })
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(.blue)
                .onReceive(self.currentLocation.$location){location in
                    if location.coordinate.latitude != 0 && location.coordinate.longitude != 0 {
                        self.appState.settings.cityLat = Double(String(format: "%.4f", location.coordinate.latitude))!
                        self.appState.settings.cityLon = Double(String(format: "%.4f", location.coordinate.longitude))!
                        self.appState.settings.useCoordinates = true
                        self.appState.settings.cityName = "\(self.appState.settings.cityLat), \(self.appState.settings.cityLon)"
                        searchCityName = "\(self.appState.settings.cityLat), \(self.appState.settings.cityLon)"
                        self.appState.settings.cityId = 0
                        self.currentLocation.stopLocationManager()
                        self.appState.settings.saveAll()
                    }
            }
            SearchButtonView(action: {
                self.tryCitySearch(){(results: [Networking.CityResponse.Result]) in
                    if results.count > 0{
                        self.options.removeAll()
                        self.options.append(contentsOf: results)
                        self.showSheet.toggle()
                    }
                }
            })
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(.blue)
            
        }
        .onAppear(){
            self.searchCityName = self.appState.settings.cityName
        }
        .actionSheet(isPresented: $showSheet){
            self.generateActionSheet(options: self.options.map({$0.name}))
        }
    }
}

struct CitySearchBaseView_Previews: PreviewProvider {
    static var previews: some View {
        CitySearchBasicView().environmentObject(AppState())
    }
}
