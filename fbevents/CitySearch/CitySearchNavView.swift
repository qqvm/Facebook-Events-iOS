//
//  CitySearchView.swift
//  fbevents
//
//  Created by User on 27.06.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI
import CoreLocation


struct CitySearchNavView: View {
    
    var body: some View {
        NavigationView{
            VStack(alignment: .center){
                CitySearchBasicView()
                    .padding()
                Spacer()
            }
            .navigationBarTitle(Text("City"), displayMode: .inline)
            .navigationBarItems(leading: MenuButtonView())
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct CitySearchView_Previews: PreviewProvider {
    static var previews: some View {
        CitySearchNavView().environmentObject(AppState())
    }
}
