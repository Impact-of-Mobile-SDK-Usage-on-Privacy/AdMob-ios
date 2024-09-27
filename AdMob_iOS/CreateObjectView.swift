//
//  ContentView.swift
//  AdMob_iOS
//
//  Created by Robin Kirchner on 29.08.23.
//

import SwiftUI


struct CreateObjectView: View {
    @EnvironmentObject var adMobManager: AdMobManager
    
    var body: some View {
        ZStack {
            VStack {
                adMobManager.statusMessage()
                Text("SDK object has been created")
            }
        }
        .onAppear {
            print("CreateObjectView.onAppear")
            adMobManager.createSdkObject()
        }
    }
}

struct CreateObjectView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a preview with a FirebaseManager instance
        let adMobManager = AdMobManager()
        
        // Wrap the StartView in a NavigationView to match your app's structure
        NavigationView {
            CreateObjectView()
                .environmentObject(adMobManager)
        }
    }
}
