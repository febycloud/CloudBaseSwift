//
//  ContentView.swift
//  fireCloud
//
//  Created by 云飛 on 8/27/20.
//  Copyright © 2020 Fei Yun. All rights reserved.
//

import SwiftUI
import Firebase
import MobileCoreServices


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
    @State var show=false
    @State var type=""
    @State var isLoading=false
    
    var body: some View{
        NavigationView{
            ZStack{
                Color.black.opacity(0.05).edgesIgnoringSafeArea(.all)
                
                ZStack(alignment: .bottomTrailing){
                    if self.data.data.count != 0{
                        ScrollView(.vertical,showsIndicators: false){
                            VStack(spacing:15){
                                ForEach(self.data.data){ i in
                                    CellView(data:i)
                                    
                                }
                            }
                        .padding()
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
                            Button(action:{
                                self.expand.toggle()
                                self.type="doc"
                                self.show.toggle()
                                
                            }){
                                                       Image(systemName: "doc.fill")
                                                       .resizable()
                                                       .frame(width: 20, height: 20)
                                                       .foregroundColor(.blue)
                                                       .padding()
                                                       
                                                   }
                                                   .background(Color.white)
                                               .clipShape(Circle())
                            
                            Button(action:{
                                self.expand.toggle()
                                self.type="img"
                                self.show.toggle()
                            }){
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
                
                if self.isLoading||(self.data.data.count == 0 && !self.data.isEmpty){
                    GeometryReader{ _ in
                        VStack{
                            Loader()
                        }
                    }.background(Color.black.opacity(0.15).edgesIgnoringSafeArea(.all))
                }
            }
            .navigationBarTitle("Cloud",displayMode: .inline)
            .navigationBarItems(trailing: Button(action:{
                
            },label: {
                VStack{
                    if self.data.data.count != 0 && !self.isLoading{
                        Button(action:{
                            NotificationCenter.default.post(name:NSNotification.Name("Updated"),object: nil)
                        }){
                            Image(systemName: "arrow.clockwise")
                            .resizable()
                            .frame(width:15,height:18)
                            .foregroundColor(.blue)
                        }
                    }
                }
            
            }))
        }
        .sheet(isPresented: self.$show){
            if self.type == "doc"{
                DocPicker(show:self.$show,isLoading: self.$isLoading)
            }else{
                ImagePicker(show:self.$show,isLoading: self.$isLoading)
            }
        }
        .onAppear{
            NotificationCenter.default.addObserver(forName: NSNotification.Name("Updated"), object: nil, queue: .main){ (_) in
                self.data.data.removeAll()
                self.data.isEmpty=false
                self.data.updateData()
            }
        }
    }
}

struct CellView:View {
    var data:Cloud
    var body:some View{
        HStack(spacing:15){
            Image(data.type=="image/jpeg" ? "pic" : "doc")
            .resizable()
            .renderingMode(.original)
            .frame(width:55, height:55)
            
            Text(getDate())
                .fontWeight(.bold)
            
            Spacer()
        }.padding()
            .background(Color.white).cornerRadius(10)
    }
    func getDate()->String{
        let format=DateFormatter()
        format.dateFormat="dd-MM-YYYY hh:mm a"
        return format.string(from: Date(timeIntervalSince1970: TimeInterval.init(Double(data.name)!)))
    }
}

struct ImagePicker:UIViewControllerRepresentable {
    
    @Binding var show:Bool
    @Binding var isLoading:Bool
    
    func makeCoordinator() -> Coordinator {
        return ImagePicker.Coordinator(parent1:self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker=UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate=context.coordinator
        return picker
    }
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        
    }
    
    class Coordinator:NSObject,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
        var parent:ImagePicker
        init(parent1:ImagePicker) {
            parent=parent1
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            self.parent.show=false
        }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            let url=info[.imageURL] as! URL
                let storage=Storage.storage()
                storage.reference().child("Cloud Data").child("\(Date().timeIntervalSince1970)").putFile(from: url, metadata:nil){ (_,err) in
                    if err != nil{
                        print((err?.localizedDescription)!)
                        return
                    }
                    
                    NotificationCenter.default.post(name:NSNotification.Name("Updated"),object: nil)
                    self.parent.isLoading=false
                }
                self.parent.show=false
                self.parent.isLoading=true
        }
        
    }
}

struct DocPicker:UIViewControllerRepresentable {
    
    @Binding var show:Bool
    @Binding var isLoading:Bool
    
    func makeCoordinator() -> Coordinator {
        return DocPicker.Coordinator(parent1:self)
    }
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker=UIDocumentPickerViewController(documentTypes: [String(kUTTypeItem)], in: .open)
        picker.allowsMultipleSelection=false
        picker.delegate=context.coordinator
        return picker
    }
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        
    }
    
    class Coordinator:NSObject,UIDocumentPickerDelegate{
        var parent:DocPicker
        init(parent1:DocPicker) {
            parent=parent1
        }
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            self.parent.show=false
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            let url=urls.first
            let storage=Storage.storage()
            storage.reference().child("Cloud Data").child("\(Date().timeIntervalSince1970)").putFile(from: url!, metadata:nil){ (_,err) in
                if err != nil{
                    print((err?.localizedDescription)!)
                    return
                }
                  NotificationCenter.default.post(name:NSNotification.Name("Updated"),object: nil)
                self.parent.isLoading=false
            }
            self.parent.show=false
            self.parent.isLoading=true
        }
        
    }
}

struct Loader : View {
    
    @State var show=false
    
    var body: some View{
        
        Circle()
            .trim(from: 0, to:0.8)
            .stroke(Color.blue,style:StrokeStyle(lineWidth:4, lineCap: .round))
            .frame(width:35,height: 35)
            .rotationEffect(.init(degrees: self.show ? 360:0))
            .animation(Animation.default.repeatForever(autoreverses: false).speed(1))
            .padding(40)
            .background(Color.white)
            .cornerRadius(15)
            .onAppear{
                self.show.toggle()
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
