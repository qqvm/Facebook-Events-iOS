//
//  PageBaseView.swift
//  fbevents
//
//  Created by User on 14.08.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI

struct PagesBaseView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appState: AppState
    @State var isModal = false
    @State var isFavoriteTab = true
    @State var pages = [Page]()
    @State var eventPager = NetworkPager()
    @State var currentPage: Page
    @State var showSearchField = false
    @State var searchKeyword = ""
    @State var pagesInFocus = [Int](){
           didSet{
               //print("LOADED", eventsInFocus.count, eventsInFocus.last, friendEvents.count, friendEvents.last?.id)
               if self.appState.loadComplete && self.appState.settings.token != "" && self.eventPager.canProceed &&
                   self.appState.isInternetAvailable && pagesInFocus.count > 0 &&
                   pagesInFocus.count <= (pages.count > 7 ? 7 : pages.count) &&
               pagesInFocus.contains(pages.last?.id ?? -1) && pagesInFocus.last != oldValue.last{
                   self.loadPagesPage()
               }
           }
       }
    
    func refreshPages() {
        if self.isFavoriteTab{
            loadPagesFromDB()
        }
        else{
            self.eventPager.reset()
            self.pages.removeAll()
            self.pagesInFocus.removeAll()
            self.loadPagesPage()
        }
        withAnimation{
            self.showSearchField = false
        }
    }
    
    func loadPagesFromDB(){
        do{
            self.pages.removeAll()
            let pages = try self.appState.dbPool!.read(Page.fetchAll)
            self.pages.append(contentsOf: pages)
        }
        catch{
            print(error)
        }
    }
    
    var body: some View {
        NavigationView{
            VStack{
                VStack{
                    if showSearchField{
                        HStack{
                            TextField("Search pages", text: self.$searchKeyword){
                                self.refreshPages()
                            }
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            GoButtonView(){
                                self.refreshPages()
                            }
                        }
                            .padding(.horizontal)
                            .padding(.top)
                    }
                    List(pages, id: \.self){page in
                        NavigationLink(destination: PageEventsView(isModal: self.isModal, currentPage: page)){
                            PagePlateView(page: page)
                            .onAppear(){
                                if self.sourcePageId == 0 && !self.isFavoriteTab{
                                    DispatchQueue.main.async {
                                        if !self.pagesInFocus.contains(page.id){
                                            self.pagesInFocus.append(page.id)
                                        }
                                    }
                                }
                            }
                            .onDisappear(){
                                if self.sourcePageId == 0 && !self.isFavoriteTab{
                                    DispatchQueue.main.async {
                                        self.pagesInFocus.removeAll(where: {$0 == page.id})
                                    }
                                }
                            }
                        }.buttonStyle(PlainButtonStyle())
                    }.listStyle(DefaultListStyle())
                }.onAppear(){
                    if self.sourcePageId != 0 && self.appState.isInternetAvailable{
                        self.loadPageEvents()
                    }
                    if self.isFavoriteTab{
                        self.loadPagesFromDB()
                    }
                    else if self.appState.settings.userId > 0 && self.friendsTotalCount == 0 && self.sourceEventId == 0{
                        if self.friends.count == 0 && self.appState.isInternetAvailable{
                            self.loadPagesPage()
                        }
                    }
                }
            }
            .navigationBarTitle(Text("Friends"), displayMode: .inline)
            .navigationBarItems(leading:
                MenuButtonView(),
                trailing:
                HStack{
                    if self.sourcePageId == 0{
                        HStack(alignment: .center, spacing: .zero){
                            RestoreButtonView(){
                                self.searchKeyword = ""
                                self.refreshPages()
                            }.disabled(self.searchKeyword == "")
                            SearchButtonView(){
                                withAnimation{
                                    self.showSearchField.toggle()
                                }
                            }
                        }.disabled(self.appState.isInternetAvailable)
                    }
                    else{
                        CloseButtonView(action:{
                            self.presentationMode.wrappedValue.dismiss()
                        }).padding(.trailing)
                    }
            })
        }
    }
}
