//
//  CustomNotificationView.swift
//  fbevents
//
//  Created by User on 06.09.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI


struct CustomNotificationView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appState: AppState
    @Binding var customNotificationDate: Date
    @State var dateRange: ClosedRange<Date>
    @State var title: String
    @State var subtitle: String
    @State var action: ()->()
    
    var body: some View {
        NavigationView{
            VStack(alignment: .center, spacing: 0){
                VStack{
                    TextField("Title", text: $title)
                    TextField("Description", text: $subtitle)
                }
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                DatePicker("Choose date:", selection: self.$customNotificationDate, in: dateRange, displayedComponents: [.date, .hourAndMinute])
                .labelsHidden()
                Button(action: {
                    self.action()
                    self.presentationMode.wrappedValue.dismiss()
                }){
                    RoundedRectangle(cornerRadius: 10)
                    .stroke(self.colorScheme == .light ? Color.black : Color.white)
                    .frame(width: 80, height: 40, alignment: .center)
                    .opacity(0.4)
                    .overlay(
                        HStack{
                            Image(systemName: "checkmark")
                            Text("Set")
                                .fixedSize()
                        }
                            .font(.system(size: 22))
                    )
                }
                Spacer()
            }
            .navigationBarTitle("Custom notification", displayMode: .inline)
            .navigationBarItems(trailing: CloseButtonView(){
                self.presentationMode.wrappedValue.dismiss()
            }.padding(.trailing))
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .background(self.colorScheme == .light ? Color(red: 0.95, green: 0.95, blue: 0.95) : Color(red: 0.13, green: 0.13, blue: 0.13))
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil) // hide keyboard on tap
        }
    }
}
