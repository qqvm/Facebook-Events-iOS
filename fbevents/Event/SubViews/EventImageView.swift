//
//  EventImageView.swift
//  fbevents
//
//  Created by User on 30.06.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI


struct EventImageView: View {
    @EnvironmentObject var appState: AppState
    var data: Data?
    @State var maxWidth: CGFloat = 365
    @State var maxHeight: CGFloat = 205
    @State var minWidth: CGFloat = 180
    @State var minHeight: CGFloat = 100
    let normalRatio: CGFloat = 1.756
    
    
    var body: some View {
        VStack{
            if let imageData = data{
                if let uiImage = UIImage(data: imageData){
                    Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(minWidth: minWidth, idealWidth: maxWidth, maxWidth: maxWidth, minHeight: minHeight, idealHeight: maxHeight, maxHeight: maxHeight, alignment: .center)
                }
                else{
                    Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .padding(.bottom)
                    .frame(width: minWidth, height: minHeight, alignment: .center)
                }
            }
            else{
                Image(systemName: "photo")
                .resizable()
                .scaledToFit()
                .padding(.bottom)
                .frame(width: minWidth, height: minHeight, alignment: .center)
            }
        }
    }
}

struct EventImageView_Previews: PreviewProvider {
    static var previews: some View {
        EventImageView().environmentObject(AppState())
    }
}
