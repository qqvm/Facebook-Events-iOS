//
//  LoginView.swift
//  fbevents
//
//  Created by User on 03.07.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI


struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @State var firstStageAuthResponse: (mid: String, uid: String, ff: String)? = nil
    @State var showSecondFactor = false
    @State private var code = ""
    @State internal var email = ""
    @State private var password = ""
    @State var success = 0
    
    fileprivate func firstStageAction() {
        self.success = 0
        if self.email.contains("@") && self.email.contains(".") && self.password.count > 1{
            self.loginFirstFactor(email: self.email, password: self.password)
        }
        else{self.success = -1}
    }
    
    fileprivate func secondStageAction() {
        self.success = 0
        if self.code.count == 6{
            if let response = self.firstStageAuthResponse {
                self.loginSecondFactor(code: self.code, machineId: response.mid, userId: response.uid, firstFactor: response.ff)
            }
            else{
                self.success = -1
                self.firstStageAuthResponse = nil
                self.showSecondFactor = false
            }
        }
        else{self.success = -1}
    }
    
    var body: some View {
        NavigationView{
            VStack(alignment: .center){
                if self.firstStageAuthResponse != nil{
                    VStack{
                        Text("2FA Code:")
                        HStack{
                            TextField("", text: $code, onCommit: {
                                self.secondStageAction()
                            })
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .border(success > 0 || appState.settings.token != "" ? Color.green : success < 0 ? Color.red : Color(UIColor.systemGray3)).cornerRadius(3)
                                .keyboardType(.numberPad)
                            Button(action: {
                                self.secondStageAction()
                            }, label: {Image(systemName: "chevron.right")})
                            .padding()
                        }.padding()
                    }.padding()
                }
                else{
                    VStack{
                        TextField("Email", text: $email, onCommit: {
                            self.firstStageAction()
                        })
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .border(success > 0 || showSecondFactor ? Color.green : success < 0 ? Color.red : Color(UIColor.systemGray3)).cornerRadius(3)
                            .keyboardType(.default)
                            .padding(.horizontal)
                        SecureField("Password", text: $password){
                            self.firstStageAction()
                        }
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .border(success > 0 ? Color.green : success < 0 ? Color.red : Color(UIColor.systemGray3)).cornerRadius(3)
                            .keyboardType(.default)
                            .padding(.horizontal)
                        Button(action: {
                            self.firstStageAction()
                        }, label: {Image(systemName: "arrow.right.circle").resizable().frame(width: 30, height: 30, alignment: .center)})
                    }.padding()
                }
                Spacer()
            }
            .navigationBarTitle(Text("Log in"), displayMode: .inline)
            .navigationBarItems(leading: MenuButtonView())
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView().environmentObject(AppState())
    }
}
