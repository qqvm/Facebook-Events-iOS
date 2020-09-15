//
//  TextView.swift
//  fbevents
//
//  Created by User on 03.09.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI


struct TextView: UIViewRepresentable {
    // It would be great to find a way to automatically set text height because current variant with getAproxTextHeight() is not perfect.
    @State var text: String
    @State var textStyle = UIFont.TextStyle.body
 
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.font = UIFont.preferredFont(forTextStyle: textStyle)
        textView.isSelectable = true
        textView.isUserInteractionEnabled = true
        textView.isEditable = false
//        textView.isScrollEnabled = false // Causes problems.
        textView.alwaysBounceVertical = false
        textView.dataDetectorTypes = UIDataDetectorTypes.all
        textView.textContainer.lineBreakMode = .byWordWrapping        
        return textView
    }
 
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = self.text
        uiView.font = UIFont.preferredFont(forTextStyle: textStyle)
    }
}
