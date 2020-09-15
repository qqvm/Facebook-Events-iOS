//
//  BirthdaysBaseView.swift
//  fbevents
//
//  Created by User on 21.06.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI


struct BaseBirthdaysNavView<Content: View>: View {
    @EnvironmentObject var appState: AppState
    
    let content: Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        NavigationView {
            VStack{
            content
        }
            .navigationBarTitle(Text("Birthdays"), displayMode: .inline)
            .navigationBarItems(leading: MenuButtonView())
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct BirthdaysBaseView_Previews: PreviewProvider {
    static var previews: some View {
        BaseBirthdaysNavView(){
            Text("Sample")
        }.environmentObject(AppState())
    }
}
