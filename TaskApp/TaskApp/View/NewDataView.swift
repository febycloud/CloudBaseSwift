//
//  NewDataView.swift
//  TaskApp
//
//  Created by 云飛 on 10/30/20.
//

import SwiftUI

struct NewDataView: View {
    @ObservedObject var HomeData : HomeViewModel
    var body: some View {
        
        VStack{
            HStack{
                Text("Add New Task")
                    .font(.system(size:65))
                    .fontWeight(.heavy)
                    .foregroundColor(.black)
                Spacer(minLength: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/)
            }
            .padding()
            
            TextEditor(text:$HomeData.content)
                .padding()
            
            Divider()
                .padding(.horizontal)
            
            HStack{
                Text("When")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Spacer(minLength: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/)
            }
            .padding()
            HStack{
                
            }
            
            Spacer(minLength: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/)
        }
        .background(Color.black.opacity(0.06).ignoresSafeArea(.all,edges: .bottom))
    }
}


