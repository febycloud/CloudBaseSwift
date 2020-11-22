//
//  Home.swift
//  TaskApp
//
//  Created by 云飛 on 10/30/20.
//

import SwiftUI

struct Home: View {
    @StateObject var homeData=HomeViewModel()
    var body: some View{
        
        Button(action: {homeData.isNewData.toggle()}, label: {
            /*@START_MENU_TOKEN@*/Text("Button")/*@END_MENU_TOKEN@*/
        }).sheet(isPresented: $homeData.isNewData, content: {
            NewDataView(HomeData: homeData)
        })
    }
}
