//
//  ImageView.swift
//  fbevents
//
//  Created by User on 13.07.2021.
//  Copyright © 2021 nonced. All rights reserved.
//

import SwiftUI

struct ImageView: View{
    let height: Int
    let width: Int
    let imageData: Data?
    
    var body: some View{
        if let imageData = imageData{
            if let uiImage = UIImage(data: imageData){
                Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 70, alignment: .leading)
                .padding(.trailing)
            }
            else{
                Image(systemName: "photo")
                .resizable()
                .scaledToFit()
                .padding(.bottom)
                .frame(width: 70, height: 70, alignment: .leading)
                .padding(.trailing)
            }
        }
        else{
            Image(systemName: "photo")
            .resizable()
            .scaledToFit()
            .padding(.bottom)
            .frame(width: 70, height: 70, alignment: .leading)
            .padding(.trailing)
        }
    }
}
