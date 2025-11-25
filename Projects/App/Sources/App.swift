import SwiftUI
import Firebase
import GoogleMobileAds

@main
struct SendadvApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var isSplashDone = false
    @State private var isSetupDone = false
    @Environment(\.scenePhase) private var scenePhase
    
    // SceneDelegate의 기능을 SwiftUI ObservableObject로 마이그레이션
    @StateObject private var adManager = SwiftUIAdManager()
    @StateObject private var reviewManager = ReviewManager()
    
    var body: some Scene {
        WindowGroup {
            TranslationScreen()
            .environmentObject(adManager)
            .environmentObject(reviewManager)
            .onAppear {
                setupAds()
            }
            .onChange(of: scenePhase) { oldPhase, newPhase in
                handleScenePhaseChange(from: oldPhase, to: newPhase)
            }
        }
    }
    
    private func setupAds() {
        guard !isSetupDone else {
            return
        }
        
        MobileAds.shared.start { [weak adManager] status in
            guard let adManager = adManager else { return }
            
            FirebaseApp.configure()
            
            adManager.setup()
            
            MobileAds.shared.requestConfiguration.testDeviceIdentifiers = ["8a00796a760e384800262e0b7c3d08fe"]

            adManager.prepare(interstitialUnit: .full, interval: 60.0)
        #if DEBUG
            adManager.prepare(openingUnit: .launch, interval: 60.0)
        #else
            adManager.prepare(interstitialUnit: .full, interval: 60.0 * 60)
            adManager.prepare(openingUnit: .launch, interval: 60.0 * 5)
        #endif
            adManager.canShowFirstTime = true
        }
        
        isSetupDone = true
    }
    
    private func handleScenePhaseChange(from oldPhase: ScenePhase, to newPhase: ScenePhase) {
        switch newPhase {
        case .active:
            handleAppDidBecomeActive()
        case .inactive:
            // 앱이 비활성화될 때의 처리
            break
        case .background:
            // 앱이 백그라운드로 갈 때의 처리
            break
        @unknown default:
            break
        }
    }
    
    private func handleAppDidBecomeActive() {
        print("scene become active")
        Task{
            defer {
                LSDefaults.increaseLaunchCount()
            }
            
            let isTest = adManager.isTesting(unit: .launch)
            
            await adManager.show(unit: .launch)
        }
    }
}
