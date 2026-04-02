//
//  HomePageView.swift
//  healthQuest
//
//  Created by Lauren Simineau on 3/28/26.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct HomePageView: View {

    @EnvironmentObject var session: SessionViewModel
    
    let firstName: String
    
    var body: some View {
        VStack {
            Text("Welcome, \(session.user?.role ?? "User")!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(Color("AccentColor"))
            
            Spacer()
            
        }
        
    }

    
}


