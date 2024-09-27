//
//  BasicFunctionalityView.swift
//  Firebase_iOS
//
//  Created by Robin Kirchner on 29.08.23.
//

import SwiftUI
import GoogleMobileAds

struct BasicFunctionalityView: View {
    @EnvironmentObject var adMobManager: AdMobManager
    
    var body: some View {
        ZStack {
            VStack {
                adMobManager.statusMessage()
                
                Button(action: adMobManager.toggleBanner, label: {
                    if adMobManager.canShowBanner {
                        HStack {
                            Image(systemName: "checkmark.circle")
                                .foregroundColor(.green)
                            Text("Toggle Banner")
                        }
                    } else {
                        HStack {
                                Image(systemName: "xmark.circle")
                                    .foregroundColor(.red)
                                Text("Toggle Banner")
                            }
                    }
                })
                .padding()
            }
        }
        .onAppear {
            print("BasicFunctionalityView.onAppear")
        }
    }
}

struct BasicFunctionalityView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a preview with a FirebaseManager instance
        let adMobManager = AdMobManager()
        
        // Wrap the StartView in a NavigationView to match your app's structure
        NavigationView {
            BasicFunctionalityView()
                .environmentObject(adMobManager)
        }
    }
}
