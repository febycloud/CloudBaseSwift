//
//  ContentView.swift
//  TaskApp
//
//  Created by 云飛 on 10/30/20.
//

import SwiftUI
import CoreData

struct ContentView: View {
    init(){
        UITextView.appearance().backgroundColor=.clear
    }
    var body : some View {
        Home()
    }
}
