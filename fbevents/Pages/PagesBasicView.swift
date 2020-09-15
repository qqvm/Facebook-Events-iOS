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
    var searchKeyword: Binding<String>?
    var showSearchField: Binding<Bool>?
    var performReload: Binding<Bool>?{
        didSet{
            if performReload?.wrappedValue ?? false{
                self.refreshPages()
                performReload?.wrappedValue = false
            }
        }
    }
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
                if showSearchField?.wrappedValue ?? false{
                    HStack{
                        TextField("Search places", text: self.searchKeyword ?? Binding.constant("")){
                            self.refreshPages()
                        }
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        GoButtonView(){
                            self.refreshPages()
                        }
                    }.disabled(!self.appState.isInternetAvailable && !isFavoriteTab)
                    .padding(.horizontal)
                    .padding(.top)
                }
                List(pages, id: \.id){(page: Page) in
                    NavigationLink(destination: PageEventsView(isSubview: self.isSubview, pageId: page.id)){
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
                }.listStyle(PlainListStyle())
            }
            .onAppear(){
                if self.appState.selectedView == .pages && self.isFavoriteTab{
                    self.loadPagesFromDB()
                }
                else if self.appState.selectedView == .pages{
                    self.showSearchField?.wrappedValue = true
                }
            }
        }
        .navigationBarTitle(Text("Pages"), displayMode: .inline)
    }
}
