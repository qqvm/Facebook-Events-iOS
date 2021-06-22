//
//  PageBaseView.swift
//  fbevents
//
//  Created by User on 14.08.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI


struct PagesBasicView: View {
    @EnvironmentObject var appState: AppState
    @State var isFavoriteTab = true
    @State var isSubview = false
    @State var pages = [Page]()
    @State var pagePager = NetworkPager()
    @Binding var searchKeyword: String
    @Binding var showSearchField: Bool
    @State var pagesInFocus = [Int](){
           didSet{
               //self.appState.logger.log("LOADED", pagesInFocus.count, pagesInFocus.last, pages.count, pages.last?.id)
               if self.appState.loadComplete && self.appState.settings.token != "" && self.pagePager.canProceed &&
                   self.appState.isInternetAvailable && pagesInFocus.count > 0 &&
                   pagesInFocus.count <= (pages.count > 8 ? 8 : pages.count) &&
               pagesInFocus.contains(pages.last?.id ?? -1) && pagesInFocus.last != oldValue.last{
                    self.appState.settings.usePagesSearchInsteadOfPlaces ? self.loadPagesSearchPage() : self.loadPlacesSearchPage()
               }
           }
       }
    
    var body: some View {
        VStack{
            VStack{
                if showSearchField{
                    HStack{
                        TextField(self.appState.settings.usePagesSearchInsteadOfPlaces ? "Search pages" : "Search places", text: self.$searchKeyword){
                            self.refreshPages()
                        }
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        GoButtonView(){
                            DispatchQueue.main.async {
                                self.refreshPages()
                            }
                        }
                    }.disabled(!self.appState.isInternetAvailable && !isFavoriteTab)
                    .padding(.horizontal)
                    .padding(.top)
                }
                VStack{
                    List{
                        if pages.count == 0{
                            EmptySection()
                        }
                        else{
                            Section{
                                ForEach(pages, id: \.id){(page: Page) in
                                    NavigationLink(destination: PageEventsView(isSubview: self.isSubview, page: page)){
                                        PagePlateView(page: page)
                                        .onAppear(){
                                            if self.appState.selectedView == .pages && !self.isFavoriteTab{
                                                DispatchQueue.main.async {
                                                    if !self.pagesInFocus.contains(page.id){
                                                        self.pagesInFocus.append(page.id)
                                                    }
                                                }
                                            }
                                        }
                                        .onDisappear(){
                                            if self.appState.selectedView == .pages && !self.isFavoriteTab{
                                                DispatchQueue.main.async {
                                                    self.pagesInFocus.removeAll(where: {$0 == page.id})
                                                }
                                            }
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                    }.listStyle(PlainListStyle())
                }.padding()
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("NeedPagesRefresh"))) {
                if $0.object != nil {
                    DispatchQueue.main.async {
                        if self.isFavoriteTab{
                            withAnimation{
                                self.showSearchField = false
                            }
                        }
                        self.refreshPages()
                    }
                }
            }
            .onAppear(){
                if self.pages.count == 0{
                    if self.appState.selectedView == .pages && self.isFavoriteTab{
                        self.loadPagesFromDB()
                    }
                    else if self.appState.selectedView == .pages{
                        self.showSearchField = true
                    }
                }
            }
        }
        .navigationBarTitle(Text("Pages"), displayMode: .inline)
    }
}
