//
//  AboutView.swift
//  fbevents
//
//  Created by User on 03.07.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI

struct InfoView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationView{
            ScrollView{
                VStack(alignment: .center){
                    Image(systemName: "info.circle")
                        .resizable()
                        .frame(width: 70, height: 70)
                        .padding()
                }
                VStack(alignment: .leading){
                    Text("FBEvents \(UserSettings.appVersion) (\(UserSettings.appBuildNumber))\n").fontWeight(.heavy)
                    + Text("All information related to Facebook and Facebook logo, including but not limiting the data shown in application, belongs to Facebook Inc.\n")
                    + Text("Facebook Inc. saves the right to change this information and/or change the way this information is provided to the end user.\n")
                    Text("FBEvents does not process any data on it's servers. All comunications are made between user and Facebook servers.\n")
                    + Text("All required information is stored on device. FBEvents does not store user credentials. User session token is stored securely in a Keychain.\n\n")
                    + Text("This program is free software: you can redistribute it and/or modify it under the terms of\nthe GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.\n\n")
                    + Text("This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.\n\n")
                    + Text("You should have received a copy of the GNU General Public License along with this program.  If not, see:")
                    Button(action: {
                        UIApplication.shared.open(URL(string: "https://www.gnu.org/licenses/")!)
                    }, label: {Text("https://www.gnu.org/licenses/")})
                }
            }.padding()
            .navigationBarTitle(Text("Info"), displayMode: .inline)
            .navigationBarItems(leading: MenuButtonView(), trailing: Text(""))
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView().environmentObject(AppState())
    }
}
