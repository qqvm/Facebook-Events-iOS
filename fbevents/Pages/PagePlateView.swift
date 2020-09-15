//
//  PagePlateView.swift
//  fbevents
//
//  Created by User on 14.08.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI

struct PagePlateView: View {
    @EnvironmentObject var appState: AppState
    @State var page: Page
    @State var isPageFavorite = false
    
    var body: some View {
        HStack{
            if self.appState.settings.downloadImages{
                WebImage(url: URL(string: page.picture))
                    .resizable()
                    .frame(width: 70, height: 70, alignment: .leading)
                    .padding(.trailing)
            }
            VStack(alignment: .leading){
                Text(page.name)
                    .font(.headline)
                Text(page.address ?? "")
                    .font(.subheadline)
            }
            Spacer()
            Button(action: {
                self.isPageFavorite.toggle()
                if self.isPageFavorite{
                    _ = self.page.save(dbPool: self.appState.dbPool!)
                }
                else{
                    _ = self.page.delete(dbPool: self.appState.dbPool!)
                }
            }){
                Image(systemName: self.isPageFavorite ? "star.fill" : "star")
                    .foregroundColor(.blue)
            }.padding(.trailing)
        }.onAppear(){
            self.isPageFavorite = self.page.exists(dbPool: self.appState.dbPool!)
        }
    }
}
