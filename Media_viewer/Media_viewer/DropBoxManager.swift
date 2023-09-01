//
//  DropBoxManager.swift
//  Media_viewer
//
//  Created by Arthur on 01.09.2023.
//

import UIKit
import SwiftyDropbox

class DropBoxManager {
    static let shared = DropBoxManager()

    private init() {}

    private let client = DropboxClientsManager.authorizedClient

    private let appKey = "yrxnpqqpzwpqgem"

    func initializeClient() {
        DropboxClientsManager.setupWithAppKey(appKey)
    }

    func showAutorization(from controller: UIViewController) {
        let scopeRequest = ScopeRequest(scopeType: .user, scopes: ["account_info.read"], includeGrantedScopes: false)
        DropboxClientsManager.authorizeFromControllerV2(
            UIApplication.shared,
            controller: controller,
            loadingStatusDelegate: nil,
            openURL: { (url: URL) -> Void in UIApplication.shared.open(url, options: [:], completionHandler: nil) },
            scopeRequest: scopeRequest
        )
    }

    func handleContext(URLContexts: Set<UIOpenURLContext>) {
        let oauthCompletion: DropboxOAuthCompletion = {
         if let authResult = $0 {
             switch authResult {
             case .success:
                 print("Success! User is logged into DropboxClientsManager.")
             case .cancel:
                 print("Authorization flow was manually canceled by user!")
             case .error(_, let description):
                 print("Error: \(String(describing: description))")
             }
         }
       }

       for context in URLContexts {
           if DropboxClientsManager.handleRedirectURL(context.url, completion: oauthCompletion) { break }
       }
    }
}
