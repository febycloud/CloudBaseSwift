//
//  HomeViewModel.swift
//  TaskApp
//
//  Created by 云飛 on 10/30/20.
//

import SwiftUI

class HomeViewModel : ObservableObject{
    @Published var content=""
    @Published var date=Date()
    
    //create new
    @Published var isNewData=false
}
