//
//  LoadView.swift
//  fbevents
//
//  Created by User on 06.07.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI


struct ActivityIndicator: UIViewRepresentable {
    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

struct LoadBasicView: View {
    var body: some View {
        VStack{
            Text("Loading...")
            ActivityIndicator(isAnimating: .constant(true), style: .large)
        }
        .frame(width: 170,
               height: 170)
        .background(Color.secondary.colorInvert())
        .foregroundColor(Color.primary)
        .cornerRadius(20)
    }
}

struct LoadView_Previews: PreviewProvider {
    static var previews: some View {
        LoadBasicView()
    }
}
