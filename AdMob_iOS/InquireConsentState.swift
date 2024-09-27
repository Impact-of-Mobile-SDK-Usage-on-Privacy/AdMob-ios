//
//  InquireConsentState.swift
//  Firebase_iOS
//
//  Created by Robin Kirchner on 28.08.23.
//

import SwiftUI
import AppTrackingTransparency
import UserMessagingPlatform
import AdSupport

func getIDFA() -> String? {
    // Check whether advertising tracking is enabled
    if #available(iOS 14, *) {
        if ATTrackingManager.trackingAuthorizationStatus != ATTrackingManager.AuthorizationStatus.authorized  {
            return "nil"
        }
    } else {
        if ASIdentifierManager.shared().isAdvertisingTrackingEnabled == false {
            return "nil"
        }
    }

    return ASIdentifierManager.shared().advertisingIdentifier.uuidString
}

func parseConsentStatus(status: UMPConsentStatus) -> AnyView {
    switch status {
    case .obtained:
        return AnyView(
            HStack {
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.green)
                Text("consent obtained")
            }
        )
    case .unknown:
        return AnyView(
            HStack {
                Image(systemName: "questionmark.circle")
                    .foregroundColor(.yellow)
                Text("consent unknown")
            }
        )
    case .required:
        return AnyView(
            HStack {
                Image(systemName: "exclamationmark")
                    .foregroundColor(.black)
                Text("consent required")
            }
        )
    case .notRequired:
        return AnyView(
            HStack {
                Image(systemName: "questionmark.exclamationmark")
                    .foregroundColor(.black)
                Text("consent not required")
            }
        )
    @unknown default:
        return AnyView(Text("default"))
    }
}

struct InquireConsentView: View {
    @EnvironmentObject var adMobManager: AdMobManager
    @State var parsedConsentStatus = parseConsentStatus(status: UMPConsentInformation.sharedInstance.consentStatus)
    
    var body: some View {
        ZStack {
            VStack {
                adMobManager.statusMessage().padding()
                
                Button(action: {
                    // update
                    updateParsedConsentStatus()
                }, label: {
                    parsedConsentStatus
                }).padding()
                
                Spacer()
                
                Button(action: requestIDFA, label: {
                    VStack{
                        HStack {
                            Image(systemName: "magnifyingglass")
                            Text("Request IDFA tracking")
                        }
                        Text(getIDFA()!)
                            .font(.system(size: 9))
                    }
                    
                })
                .padding()
                
                Button(action: showConsentInformation, label: {
                    HStack {
                        Image(systemName: "square.and.pencil")
                        Text("Request consent form")
                    }
                })
                .padding()
                
                Button(action: {
                    UMPConsentInformation.sharedInstance.reset()
                    updateParsedConsentStatus()
                }, label: {
                    HStack {
                        Image(systemName: "trash")
                        Text("Reset consent")
                    }
                })
                .padding()
                
            }
        }
        .onAppear {
            UMPDebugSettings().geography = .EEA  // set to fixed EEA location
            print("InquireConsentView.onAppear")
            updateParsedConsentStatus()
        }
    }
    
    func updateParsedConsentStatus() {
        parsedConsentStatus = parseConsentStatus(status: UMPConsentInformation.sharedInstance.consentStatus)
    }
    
    
    private func requestIDFA() {
        ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
            // Tracking authorization completed. Start loading ads here.
            print("Tracking authorization completed. To show this again, the testing app needs to be uninstalled!")
        })
    }
    
    private func showConsentInformation() {
        let parameters = UMPRequestParameters()
        
        // false means users are not under age.
        parameters.tagForUnderAgeOfConsent = false
        
        UMPConsentInformation.sharedInstance.requestConsentInfoUpdate(
            with: parameters,
            completionHandler: { error in
                if error != nil {
                    // Handle the error.
                    print("Error in requestConsentInfoUpdate", error!)
                } else {
                    // The consent information state was updated.
                    // You are now ready to check if a form is
                    // available.
                    loadForm()
                }
            })
        updateParsedConsentStatus()
    }
    
    func loadForm() {
        print("loadForm: UMPConsentForm.load")
        UMPConsentForm.load(
            completionHandler: { form, loadError in
                if loadError != nil {
                    // Handle the error
                    print("Error in UMPConsentForm.load", loadError!)
                    updateParsedConsentStatus()
                } else {
                    print("UMPConsentForm.load succeeded, presenting form...")
                    // Present the form
                    /*if UMPConsentInformation.sharedInstance.consentStatus == UMPConsentStatus.required {
                     form?.present(from: UIApplication.shared
                     .connectedScenes
                     .compactMap { ($0 as? UIWindowScene)?.keyWindow }
                     .last!.rootViewController! as UIViewController, completionHandler: { dimissError in
                     if UMPConsentInformation.sharedInstance.consentStatus == UMPConsentStatus.obtained {
                     // App can start requesting ads.
                     print("UMPConsentInformation.sharedInstance.consentStatus == UMPConsentStatus.obtained")
                     // adMobManager.configure()
                     }
                     })
                     }*/
                    
                    if UMPConsentInformation.sharedInstance.consentStatus == UMPConsentStatus.required {
                        form?.present(
                            from: UIApplication
                                .shared
                                .windows.first!
                                //.last!
                                .rootViewController! as UIViewController,
                            completionHandler: {
                                dimissError in
                                updateParsedConsentStatus()
                                if UMPConsentInformation.sharedInstance.consentStatus == UMPConsentStatus.obtained {
                                    // App can start requesting ads.
                                    print("UMPConsentStatus.obtained: App can start requesting ads.")
                                    updateParsedConsentStatus()
                                }
                            })
                    }
                }
            })
    }
}

struct InquireConsentView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a preview with a FirebaseManager instance
        let adMobManager = AdMobManager()
        
        // Wrap the StartView in a NavigationView to match your app's structure
        NavigationView {
            InquireConsentView()
                .environmentObject(adMobManager)
        }
    }
}
