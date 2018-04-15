//
//  AppDelegate.swift
//  talktrans
//
//  Created by 영준 이 on 2016. 12. 2..
//  Copyright © 2016년 leesam. All rights reserved.
//

import UIKit
import CoreData
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GADInterstialManagerDelegate, ReviewManagerDelegate, GADRewardManagerDelegate {

    var window: UIWindow?
    var fullAd : GADInterstialManager?;
    var rewardAd : GADRewardManager?;
    var reviewManager : ReviewManager?;
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        GADMobileAds.configure(withApplicationID: "ca-app-pub-9684378399371172~6560332448");
        FirebaseApp.configure()
        
        self.reviewManager = ReviewManager(self.window!, interval: 60.0 * 60 * 24 * 2);
        self.reviewManager?.delegate = self;
        //self.reviewManager?.show();
        
        self.rewardAd = GADRewardManager(self.window!, unitId: GADInterstitial.loadUnitId(name: "RewardAd") ?? "", interval: 60.0 * 60.0 * 6); //
        self.rewardAd?.delegate = self;
        self.fullAd = GADInterstialManager(self.window!, unitId: GADInterstitial.loadUnitId(name: "FullAd") ?? "", interval: 60.0 * 60 * 3);
        self.fullAd?.delegate = self;
        self.fullAd?.canShowFirstTime = false;
        
        if self.rewardAd?.canShow ?? false{
            self.fullAd?.show();
        }

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        guard self.reviewManager?.canShow ?? false else{
            return;
        }
        self.reviewManager?.show();
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
//    static var test : UIInterfaceOrientationMask = .portrait;
//    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
//        return AppDelegate.test;
//    }

    // MARK: GADInterstialManagerDelegate
    func GADInterstialGetLastShowTime() -> Date {
        return TTDefaults.LastFullADShown;
        //Calendar.current.component(<#T##component: Calendar.Component##Calendar.Component#>, from: <#T##Date#>)
    }
    
    func GADInterstialUpdate(showTime: Date) {
        TTDefaults.LastFullADShown = showTime;
    }
    
    func GADInterstialWillLoad() {
        //DAInfoTableViewController.shared?.needAds = false;
        //DAFavoriteTableViewController.shared?.needAds = false;
    }
    
    // MARK: ReviewManagerDelegate
    func reviewGetLastShowTime() -> Date {
        return TTDefaults.LastShareShown;
    }
    
    func reviewUpdate(showTime: Date) {
        TTDefaults.LastShareShown = showTime;
    }
    
    // MARK: GADRewardManagerDelegate
    func GADRewardGetLastShowTime() -> Date {
        return TTDefaults.LastRewardShown;
    }
    
    func GADRewardUserCompleted() {
        TTDefaults.LastRewardShown = Date();
    }
    
    func GADRewardUpdate(showTime: Date) {
        
    }
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "talktrans")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

