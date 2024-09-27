//
//  InitializeSDKView.swift
//  Firebase_iOS
//
//  Created by Robin Kirchner on 29.08.23.
//

import SwiftUI

struct InitializeSDKView: View {
    @EnvironmentObject var adMobManager: AdMobManager
    
    var body: some View {
        ZStack {
            VStack {
                adMobManager.statusMessage()
            }
        }
        .onAppear {
            adMobManager.configure()
            print("InitializeSDKView.onAppear")
        }
    }
}

struct InitializeSDKView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a preview with a FirebaseManager instance
        let adMobManager = AdMobManager()
        
        // Wrap the StartView in a NavigationView to match your app's structure
        NavigationView {
            InitializeSDKView()
                .environmentObject(adMobManager)
        }
    }
}
