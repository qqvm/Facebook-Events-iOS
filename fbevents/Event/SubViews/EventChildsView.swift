//
//  EventChildsView.swift
//  fbevents
//
//  Created by User on 05.08.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI


struct EventChildsView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appState: AppState
    @State var originId = 0
    @State var childs = [SimpleChildEvent]()
    @State var parentId = 0

    
    var body: some View {
        VStack{
            VStack{
                List(childs, id: \.self){(child: SimpleChildEvent) in
                    NavigationLink(destination: EventView(eventId: child.id, originId: self.originId)){
                        VStack{
                            Text(AppState.getFormattedDate(child.startTimestamp))
                                .font(.headline)
                                .fontWeight(.thin)
                        }
                    }.disabled(child.id == self.originId)
                    .buttonStyle(PlainButtonStyle())
                }.listStyle(DefaultListStyle())
            }
        }
        .navigationBarTitle("Future events", displayMode: .inline)
        .background(self.colorScheme == .light ? Color(red: 0.95, green: 0.95, blue: 0.95) : Color(red: 0.13, green: 0.13, blue: 0.13))
        .onAppear(){
            if self.childs.count == 0 && self.parentId != 0{
                if let event = Event.get(id: self.parentId, dbPool: self.appState.cacheDbPool!){
                    DispatchQueue.main.async {
                        if let childs = event.childEvents{
                            self.childs.append(contentsOf: childs)
                        }
                    }
                }
                else{
                    self.appState.loadEventDetails(eventId: self.parentId){ev in
                        if let childs = ev.childEvents{
                            self.childs.append(contentsOf: childs)
                        }
                    }
                }
            }
        }
    }
}

struct EventChildsView_Previews: PreviewProvider {
    static var previews: some View {
        EventChildsView(childs: [SimpleChildEvent]()).environmentObject(AppState())
    }
}
