//
//  ContentView.swift
//  fireCloud
//
//  Created by 云飛 on 8/27/20.
//  Copyright © 2020 Fei Yun. All rights reserved.
//

import SwiftUI
import Firebase

struct ContentView: View {
    var body: some View {
        Home()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct Home:View {
    
    @State var expand=false
    @ObservedObject var data=getData()
    
    var body: some View{
        NavigationView{
            ZStack{
                Color.black.opacity(0.05).edgesIgnoringSafeArea(.all)
                
                ZStack(alignment: .bottomTrailing){
                    if self.data.data.count != 0{
                        ScrollView(.vertical,showsIndicators: false){
                            VStack(spacing:15){
                                ForEach(self.data.data){ i in
                                    Text(i.name)
                                    
                                }
                            }
                        }
                    }
                    if self.data.isEmpty{
                        GeometryReader{ _ in
                            VStack{
                               Text("No document avaliable")
                            }
                            
                        }
                    }
                    VStack(spacing:18){
                        
                        if self.expand{
                            Button(action:{}){
                                                       Image(systemName: "doc.fill")
                                                       .resizable()
                                                       .frame(width: 20, height: 20)
                                                       .foregroundColor(.blue)
                                                       .padding()
                                                       
                                                   }
                                                   .background(Color.white)
                                               .clipShape(Circle())
                            
                            Button(action:{}){
                                               Image(systemName: "photo.fill")
                                               .resizable()
                                               .frame(width: 20, height: 20)
                                               .foregroundColor(.blue)
                                               .padding()
                                               
                                           }
                                           .background(Color.white)
                                       .clipShape(Circle())
                        }
                        
                        Button(action:{
                            withAnimation(.spring()){
                                self.expand.toggle()
                            }
                        }){
                            Image(systemName: self.expand ? "xmark":"plus")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.blue)
                            .padding()
                            
                        }
                        .background(Color.white)
                    .clipShape(Circle())
                    }
                .padding()
                }
            }
        }
    }
}

class getData:ObservableObject{
    
    @Published var data=[Cloud]()
    @Published var isEmpty=false
    
    init(){
        updateData()
    }
    
    func updateData(){
        let storage=Storage.storage()
        storage.reference().child("Cloud Data").listAll{(res,err) in
            if err != nil{
                print((err?.localizedDescription)!)
                self.isEmpty=true
                return
            }
            if res.items.isEmpty{
                self.isEmpty=true
            }
            for i in 0..<res.items.count{
                let name = res.items[i].name
                
                res.items[i].getMetadata{(meta,err) in
                    if err != nil{
                        print((err?.localizedDescription)!)
                        return
                    }
                    let type=meta?.contentType
                    res.items[i].downloadURL{(url,err) in
                        if err != nil{
                                               print((err?.localizedDescription)!)
                                               return
                                           }
                        DispatchQueue.main.async {
                            self.data.append(Cloud(id: i, name: name, type: type!, url: "\(url!)"))
                        }
                        
                    }
                    
                }
            }
        }
    }
    
    
}

struct Cloud:Identifiable {
    var id:Int
    var name:String
    var type:String
    var url:String
    
}
