//
//  HomePageView.swift
//  healthQuest
//
//  Created by Lauren Simineau on 3/28/26.
//

import SwiftUI
import FirebaseAuth


struct HomePageView: View {

    
    let firstName: String
    var body: some View {
        VStack {
            Text("Welcome, \(firstName)!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(Color("AccentColor"))
            Text("uhhh idk what should be on this page yet")
            Text("maybe notifications from therapists")
            Spacer()
            
        }
        
    }
    
    
    
    
}


