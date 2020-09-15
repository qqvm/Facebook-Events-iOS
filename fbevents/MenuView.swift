//
//  MenuView.swift
//  fbevents
//
//  Created by User on 21.06.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI

struct MenuView: View {
    @EnvironmentObject var appState: AppState
    var mainColor = Color(.lightGray)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Menu")
                .foregroundColor(mainColor)
                .font(.title)
                .padding(.top, 15)
            Button(action: {withAnimation{self.appState.selectedView = .events; self.appState.showMenu.toggle()}}){
                HStack {
                    Image(systemName: "calendar")
                    Text("Events")
                    Spacer()
                }
            }
            Button(action: {withAnimation{self.appState.selectedView = .favorites; self.appState.showMenu.toggle()}}){
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(mainColor)
                    Text("Favorites")
                        .foregroundColor(mainColor)
                    Spacer()
                }
            }
            Button(action: {withAnimation{self.appState.selectedView = .friends; self.appState.showMenu.toggle()}}){
                HStack {
                    Image(systemName: "person.crop.circle")
                    Text("Friends")
                    Spacer()
                }
            }
            Button(action: {withAnimation{self.appState.selectedView = .birthdays; self.appState.showMenu.toggle()}}){
                HStack {
                    Image(systemName: "gift")
                    Text("Birthdays")
                    Spacer()
                }
            }
            Button(action: {withAnimation{self.appState.selectedView = .pages; self.appState.showMenu.toggle()}}){
                HStack {
                    Image(systemName: "doc.plaintext")
                    Text("Pages")
                    Spacer()
                }
            }
            Button(action: {withAnimation{self.appState.selectedView = .settings; self.appState.showMenu.toggle()}}){
                HStack {
                    Image(systemName: "gear")
                    Text("Settings")
                    Spacer()
                }
            }
            Button(action: {withAnimation{self.appState.selectedView = .about; self.appState.showMenu.toggle()}}){
                HStack {
                    Image(systemName: "info.circle")
                    Text("Info")
                    Spacer()
                }
            }
            if self.appState.settings.token != ""{
                Button(action: {withAnimation{self.appState.logout(); self.appState.showMenu.toggle()}}){
                    HStack {
                        Image(systemName: "power")
                        Text("Log out")
                        Spacer()
                    }
                }
            }
            Spacer()
        }
        .padding(.leading)
        .padding()
        .foregroundColor(mainColor)
        .font(.system(size: UserSettings.buttonSize, weight: .light, design: .default))
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 0.12, green: 0.12, blue: 0.12))
        .edgesIgnoringSafeArea(.all)
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView().environmentObject(AppState())
    }
}
