    //
    //  ContentView.swift
    //  AdDemoApp
    //
    //  Created by Saiful Islam Sagor on 17/10/23.
    //

import SwiftUI
import GoogleMobileAds
//import UIKit

final class RewardAdsManager: NSObject,GADFullScreenContentDelegate,ObservableObject{
    
        // Properties
    @Published var rewardLoaded:Bool = false
    var rewardAd:GADRewardedAd?
    
    override init() {
        super.init()
    }
    
        // Load reward ads
    func loadReward(){
        GADRewardedAd.load(withAdUnitID: "ca-app-pub-3940256099942544/5224354917", request: GADRequest()) { add, error in
            if let error  = error {
                print("🔴: \(error.localizedDescription)")
                self.rewardLoaded = false
                return
            }
            print("🟢: Loading succeeded")
            self.rewardLoaded = true
            self.rewardAd = add
            self.rewardAd?.fullScreenContentDelegate = self
        }
    }
    
        // Display reward ads
    func displayReward(){
        guard let root = UIApplication.shared.windows.first?.rootViewController else {
            return
        }
        
        if let ad = rewardAd{
            ad.present(fromRootViewController: root) {
                print("🟢: Earned a reward")
                self.rewardLoaded = false
            }
        } else {
            print("🔵: Ad wasn't ready")
            self.rewardLoaded = false
            self.loadReward()
        }
    }
}

struct AppOpenAdView: UIViewControllerRepresentable{
    var AppOpenAdId: String
    
    func makeUIViewController(context: Context) -> UIViewController {
        let adViewController = UIViewController()
        
        //Load the AppOpenAd
        GADAppOpenAd.load(withAdUnitID: AppOpenAdId, request: GADRequest()){(ad,error) in
            if let error = error{
                print("Failed to load App open Ad with error: \(error.localizedDescription)")
                return
            }
            if let appOpenAd = ad{
                appOpenAd.fullScreenContentDelegate = context.coordinator
                    appOpenAd.present(fromRootViewController: adViewController)
            }
        }
        return adViewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) { }
    
    class Coordinator: NSObject, GADFullScreenContentDelegate{
        func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
                // Handle app open ad dismissal if needed
        }
    }
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    typealias UIViewControllerType = UIViewController
}



//struct AppOpenAdView: UIViewControllerRepresentable {
//
//    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
//            // No need to implement anything here
//    }
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator()
//    }
//
//    class Coordinator: NSObject, GADFullScreenContentDelegate {
//        func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
//                // Handle app open ad dismissal if needed
//        }
//    }
//
//        //    typealias UIViewControllerType = UIViewController
//
//    func makeUIViewController(context: Context) -> UIViewController {
//        let adViewController = UIViewController()
//
//            // Load the app open ad
//        GADAppOpenAd.load(
//            withAdUnitID: "ca-app-pub-3940256099942544/3419835294",
//            request: GADRequest(),
//            orientation: UIApplication.shared.windows.first?.windowScene?.interfaceOrientation ?? .unknown
//        ) { (ad, error) in
//            if let error = error {
//                print("Failed to load app open ad with error: \(error.localizedDescription)")
//                return
//            }
//
//            if let appOpenAd = ad {
//                appOpenAd.fullScreenContentDelegate = context.coordinator
//
//                do {
//                    try appOpenAd.present(fromRootViewController: adViewController)
//                } catch {
//                    print("Failed to present app open ad with error: \(error.localizedDescription)")
//                }
//            }
//        }
//
//        return adViewController
//    }
//
//}

//final class BannerVC: UIViewControllerRepresentable  {
//
//    func makeUIViewController(context: Context) -> UIViewController {
//        let adSize = GADCurrentOrientationInlineAdaptiveBannerAdSizeWithWidth(UIScreen.main.bounds.width)
//        print(adSize.size)
//        let view = GADBannerView(adSize: adSize)
//
//        let viewController = UIViewController()
//        view.adUnitID = "ca-app-pub-3940256099942544/9214589741"
//        view.rootViewController = viewController
//        viewController.view.addSubview(view)
//        viewController.view.frame = CGRect(origin: .zero, size: adSize.size)
//        view.load(GADRequest())
//
//        return viewController
//    }
//
//    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
//}

struct BannerAdView : UIViewRepresentable{
    
    var bannerId: String
    var banner = GADBannerView(adSize: GADCurrentOrientationInlineAdaptiveBannerAdSizeWithWidth(UIScreen.main.bounds.width))
    
    func makeUIView(context: Context) -> GADBannerView {
        banner.adUnitID = bannerId
        banner.rootViewController = UIApplication.shared.windows.first?.rootViewController
        banner.load(GADRequest())
        banner.delegate = context.coordinator
        return banner
    }
    
    func updateUIView(_ uiView: GADBannerView, context: Context) { }
    
    class Coordinator : NSObject, GADBannerViewDelegate {
        var parent : BannerAdView
        
        init(_ parent: BannerAdView){
            self.parent = parent
        }
       
        func adViewDidReceiveAd(_ bannerView: GADBannerView){
            print("Ad received")
        }
        func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error){
            print("Error when Receiveiving ads: \(error.localizedDescription)")
        }
    
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    typealias UIViewType = GADBannerView
}

struct ContentView: View {
    @State var interstitial: GADInterstitialAd?
        // Properties
    @StateObject private var rewardManager = RewardAdsManager()
    var body: some View {
        NavigationView {
            
            ScrollView(.vertical,showsIndicators: true){
                ZStack{
                    AppOpenAdView(AppOpenAdId: "ca-app-pub-3940256099942544/3419835294")
                    VStack(alignment: .center){
                        
                        let text1 = "Adaptive banners are the next generation of responsive ads, maximizing performance by optimizing ad size for each device. Improving on smart banners, which only supported fixed heights, adaptive banners let developers specify the ad-width and use this to determine the optimal ad size.To pick the best ad size, adaptive banners use fixed aspect ratios instead of fixed heights. This results in banner ads that occupy a more consistent portion of the screen across devices and provide opportunities for improved performance.When working with adaptive banners, note that these will always return a constant size for a given device and width. Once you've tested your layout on a given device, you can be sure that the ad size will not change. However, the size of the banner creative may change across different devices. Consequently, it is recommended to ensure your layout can accommodate variances in ad height. In rare cases, the full adaptive size may not be filled and a standard size creative will be centered in this slot instead.When to use adaptive bannersAdaptive banners are designed to be a drop-in replacement for the industry standard 320x50 banner size, as well as the smart banner format they supersede.These banner sizes are commonly used as anchored banners, which are usually locked to the top or bottom of the screen."
                        let text2 = " For such anchored banners, the aspect ratio when using adaptive banners will be similar to that of a standard 320x50 ad, as can be seen in these screenshots. Adaptive banners are the next generation of responsive ads, maximizing performance by optimizing ad size for each device. Improving on smart banners, which only supported fixed heights, adaptive banners let developers specify the ad-width and use this to determine the optimal ad size.To pick the best ad size, adaptive banners use fixed aspect ratios instead of fixed heights. This results in banner ads that occupy a more consistent portion of the screen across devices and provide opportunities for improved performance.When working with adaptive banners, note that these will always return a constant size for a given device and width. Once you've tested your layout on a given device, you can be sure that the ad size will not change. However, the size of the banner creative may change across different devices. Consequently, it is recommended to ensure your layout can accommodate variances in ad height. In rare cases, the full adaptive size may not be filled and a standard size creative will be centered in this slot instead.When to use adaptive bannersAdaptive banners are designed to be a drop-in replacement for the industry standard 320x50 banner size, as well as the smart banner format they supersede.These banner sizes are commonly used as anchored banners, which are usually locked to the top or bottom of the screen. For such anchored banners, the aspect ratio when using adaptive banners will be similar to that of a standard 320x50 ad, as can be seen in these screenshots "
                        Text(text1)
                            .font(.headline)
//                        BannerVC()
//                            .frame(height: 400)
                        BannerAdView(bannerId: "ca-app-pub-3940256099942544/9214589741")
                            .frame(height: 600)
                        Text(text2)
                            .font(.headline)
//                            .padding(.top, -60)
                        HStack {
                            Button {
                                rewardManager.displayReward()
                            } label: {
                                Text("Show Reward")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .padding()
                                    .cornerRadius(10)

                            }
                            Button{
                                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                                let rootViewController = windowScene?.windows.first?.rootViewController
                                if let root = rootViewController {
                                    interstitial!.present(fromRootViewController: root)
                                } else {
                                    print("Ad not ready yet. Please try again later.")
                                }
                            }label:{
                                Text("Show Ads")
                            }
                        }
                        
                        
                    }
                    .padding(.top,20)
                }
                .onAppear{
                    loadInterstitialAd()
                    rewardManager.loadReward()
                }
            }
            .navigationTitle("Google AdMob")
            .navigationBarTitleDisplayMode(.inline)
        }
        
  
        
        
    }
    func loadInterstitialAd() {
        let adUnitID = "ca-app-pub-3940256099942544/4411468910"
        
        let request = GADRequest()
        GADInterstitialAd.load(
            withAdUnitID: adUnitID,
            request: request
        ) { (ad, error) in
            if let error = error {
                print("Failed to load interstitial ad: \(error.localizedDescription)")
                return
            }
            self.interstitial = ad
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
