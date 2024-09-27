//
//  AdMob_iOSApp.swift
//  AdMob_iOS
//
//  Created by Robin Kirchner on 29.08.23.
//

import SwiftUI
import GoogleMobileAds


class AdMobManager: ObservableObject {
    @Published var isCreated = false
    @Published var isConfigured = false
    @Published var canShowBanner = false
    
    func createSdkObject() {
        guard !isCreated else {
            print("AdMob SDK object is already created. Skipping.")
            return
        }
        
        GADMobileAds.sharedInstance()
        print("GADMobileAds.sharedInstance()")
        isCreated = true
    }
    
    func configure() {
        guard !isConfigured else {
            print("AdMob is already configured. Skipping.")
            return
        }
        
        GADMobileAds.sharedInstance().start(completionHandler: nil) // call GADMobileAds.sharedInstance() in a previous stage
        print("AdMob.configure()")
        isConfigured = true
    }
    
    func toggleBanner() {
        print("toggleBanner")
        canShowBanner = !canShowBanner
    }
    
    func conditionalBannerView() -> AnyView {
        guard isConfigured && canShowBanner else {
            return AnyView(EmptyView())
        }
        
        return AnyView(BannerView())
    }
    
    func extendedFunctionality() {
        print("logExtended()")
        // ...
    }
    
    func statusMessage() -> some View {
        if isConfigured {
            return AnyView(
                HStack {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(.green)
                    Text("AdMob is configured")
                }
            )
        } else {
            return AnyView(
                HStack {
                    Image(systemName: "xmark.circle")
                        .foregroundColor(.red)
                    Text("AdMob is not configured")
                }
            )
        }
    }
}

struct NamedView {
    let name: String
    let view: AnyView
}

// AdMob: Create, Consent, Init, Util
let views: [NamedView] = [
    NamedView(name: "Start", view: AnyView(ContentView())),
    NamedView(name: "Create SDK Object", view: AnyView(ContentView())), // TODO
    NamedView(name: "Inquire Consent", view: AnyView(InquireConsentView())),
    NamedView(name: "Initialize SDK", view: AnyView(InitializeSDKView())),
    NamedView(name: "Basic Functionality", view: AnyView(BasicFunctionalityView())),
]

@main
struct AdMob_iOSApp: App {
    @StateObject var adMobManager = AdMobManager()
    @State private var currentViewIndex = 0
    
    // @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @ViewBuilder
    func debugStatusMessage() -> some View {
        #if DEBUG
            AnyView(
                HStack {
                    Image(systemName: "xmark.circle")
                        .foregroundColor(.orange)
                    Text("running in DEBUG mode.")
                }
            )
        #else
            AnyView(
                HStack {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(.green)
                    Text("running in release mode.")
                }
            )
        #endif
    }
    
    func advanceViewIndex() -> AnyView {
        if currentViewIndex < views.count - 1 {
            return AnyView(
                Button(action: {
                    currentViewIndex += 1
                }, label: {
                    HStack {
                        Text("Go to \(views[currentViewIndex + 1].name)")
                        Image(systemName: "chevron.right")
                    }
                })
                .padding()
            )
        }
        return AnyView(
            Text("Final View reached.")
                .padding()
        )
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                VStack {
                    VStack {
                        Text("AdMob iOS")
                            .font(.system(size: 40))
                            .fontWeight(.heavy)
                            .multilineTextAlignment(.center)
                            .padding()
                        Text("\(views[currentViewIndex].name)")
                            .font(.system(size: 36))
                            .fontWeight(.heavy)
                            .multilineTextAlignment(.center)
                            .padding()
                        Spacer()
                        debugStatusMessage()
                            .padding()
                        // Display the current view
                        views[currentViewIndex].view
                            .environmentObject(adMobManager)
                        Spacer()
                        // Display "Next View" button
                        advanceViewIndex()
                    }
                    Spacer()
                    VStack {
                        adMobManager.conditionalBannerView()
                            .frame(height: 75)
                    }
                    .frame(height: 75)
                }
                .environmentObject(adMobManager)
            }
        }
    }
}



private struct BannerView: UIViewControllerRepresentable {
    @State private var viewWidth: CGFloat = .zero
    private let bannerView = GADBannerView()
    private let adUnitID = "<confidential>"
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let bannerViewController = BannerViewController()
        bannerView.adUnitID = adUnitID
        bannerView.rootViewController = bannerViewController
        bannerView.delegate = context.coordinator
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        bannerViewController.view.addSubview(bannerView)
        // Constrain GADBannerView to the bottom of the view.
        NSLayoutConstraint.activate([
            bannerView.bottomAnchor.constraint(
                equalTo: bannerViewController.view.safeAreaLayoutGuide.bottomAnchor),
            bannerView.centerXAnchor.constraint(equalTo: bannerViewController.view.centerXAnchor),
        ])
        bannerViewController.delegate = context.coordinator
        
        return bannerViewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        guard viewWidth != .zero else { return }
        
        bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
        bannerView.load(GADRequest())
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    fileprivate class Coordinator: NSObject, BannerViewControllerWidthDelegate, GADBannerViewDelegate
    {
        let parent: BannerView
        
        init(_ parent: BannerView) {
            self.parent = parent
        }
        
        // MARK: - BannerViewControllerWidthDelegate methods
        
        func bannerViewController(
            _ bannerViewController: BannerViewController, didUpdate width: CGFloat
        ) {
            parent.viewWidth = width
        }
        
        // MARK: - GADBannerViewDelegate methods
        
        func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
            print("DID RECEIVE AD")
        }
        
        func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
            print("DID NOT RECEIVE AD: \(error.localizedDescription)")
        }
    }
}

protocol BannerViewControllerWidthDelegate: AnyObject {
    func bannerViewController(_ bannerViewController: BannerViewController, didUpdate width: CGFloat)
}

class BannerViewController: UIViewController {
    
    weak var delegate: BannerViewControllerWidthDelegate?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        delegate?.bannerViewController(
            self, didUpdate: view.frame.inset(by: view.safeAreaInsets).size.width)
    }
    
    override func viewWillTransition(
        to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator
    ) {
        coordinator.animate { _ in
            // do nothing
        } completion: { _ in
            self.delegate?.bannerViewController(
                self, didUpdate: self.view.frame.inset(by: self.view.safeAreaInsets).size.width)
        }
    }
}
