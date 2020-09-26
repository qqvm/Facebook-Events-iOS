//
//  EventImageView.swift
//  fbevents
//
//  Created by User on 30.06.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI


struct EventImageView: View {
    @EnvironmentObject var appState: AppState
    var url: URL?
    @State var maxWidth: CGFloat = 365
    @State var maxHeight: CGFloat = 205
    @State var minWidth: CGFloat = 180
    @State var minHeight: CGFloat = 100
    let normalRatio: CGFloat = 1.756
    
    
    var body: some View {
        VStack{
            if url != nil && (self.appState.settings.downloadImages || self.appState.selectedView == .favorites){
                WebImage(url: url)
                    .placeholder(){
                        Image(systemName: "photo")
                        .resizable()
                        .frame(width: 70, height: 70, alignment: .center)
                    }
                    .resizable()
                    .scaledToFit()
                    .frame(minWidth: minWidth, idealWidth: maxWidth, maxWidth: maxWidth, minHeight: minHeight, idealHeight: maxHeight, maxHeight: maxHeight, alignment: .center)
            }
            else{
                Image(systemName: "photo")
                .resizable()
                .frame(width: 70, height: 70, alignment: .center)
                    .padding(.bottom)
            }
        }
    }
}

struct EventImageView_Previews: PreviewProvider {
    static var previews: some View {
        EventImageView().environmentObject(AppState())
    }
}
