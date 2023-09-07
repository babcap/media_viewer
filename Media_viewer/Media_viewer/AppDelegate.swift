//
//  AppDelegate.swift
//  Media_viewer
//
//  Created by Arthur on 01.09.2023.
//

import UIKit
import Adjust

@main
class AppDelegate: UIResponder, UIApplicationDelegate {


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        DropBoxManager.shared.initializeClient()

        let yourAppToken = "{YourAppToken}"
        let adjustConfig = ADJConfig(
            appToken: yourAppToken,
            environment: ADJEnvironmentSandbox)
        adjustConfig?.logLevel = ADJLogLevelVerbose
        Adjust.appDidLaunch(adjustConfig)
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }


}

