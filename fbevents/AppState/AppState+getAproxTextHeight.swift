//
//  AppState+getAproxTextHeight.swift
//  fbevents
//
//  Created by User on 11.09.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI


extension AppState {
    func getAproxTextHeight(_ text: String) -> CGFloat{
        /* This function calculates approximate text height, so result may be not perfect.
         Looking for replacement. */
        let label: UILabel = .init()
        label.text = text
        label.numberOfLines = 0
        label.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
        label.lineBreakMode = .byWordWrapping
        let size = label.sizeThatFits(CGSize.init(width: UIScreen.main.bounds.width - 40, height: .infinity))
        
        let newLines = CGFloat(text.filter({$0 == "\n"}).count)
        
        return size.height + ((newLines > 8 ? newLines : 8) * UIFont.preferredFont(forTextStyle: (UIFont.TextStyle.body)).lineHeight / (newLines > 8 ? 3.4 : 2.4))
    }
}
