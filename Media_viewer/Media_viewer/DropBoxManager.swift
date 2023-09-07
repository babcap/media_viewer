//
//  DropBoxManager.swift
//  Media_viewer
//
//  Created by Arthur on 01.09.2023.
//

import UIKit
import SwiftyDropbox

typealias DownloadedFileCompletion = ((Files.FileMetadata, URL)?) -> Void

class DropBoxManager {
    static let shared = DropBoxManager()

    private init() {}

    private let appKey = "yrxnpqqpzwpqgem"
    let loginNotificationName = Notification.Name(rawValue: "SuccessLogin")

    private let downloadQueue = DispatchQueue(label: "DownloadQueue")
    private var cursor: String?
    private (set) var isMaxCount: Bool = false
    private (set) var files: [(Files.FileMetadata, URL)] = [(Files.FileMetadata, URL)]()

    func initializeClient() {
        DropboxClientsManager.setupWithAppKey(appKey)
    }

    func showAutorization(from controller: UIViewController) {
        let scopeRequest = ScopeRequest(scopeType: .user, scopes: ["account_info.read", "files.metadata.read", "files.content.read"], includeGrantedScopes: false)
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

                 NotificationCenter.default.post(Notification(name: self.loginNotificationName))

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

    func downloadFiles(with completion: DownloadedFileCompletion?) {

        func handleResponse(response: Files.ListFolderResult) {
            self.isMaxCount = !response.hasMore
            response.entries.forEach {
                self.downloadFile(name: $0.name, path: $0.pathLower ?? "", completion: completion)
            }
        }

        guard !self.isMaxCount else { return }

        if let cursor = cursor {
            DropboxClientsManager.authorizedClient?.files.listFolderContinue(cursor: cursor).response(queue: downloadQueue) { response, error in

                if let result = response {
                    handleResponse(response: result)
                } else if let error = error {
                    debugPrint(error)
                }
            }
        } else {
            DropboxClientsManager.authorizedClient?.files.listFolder(path: "", limit: 20).response(queue: downloadQueue) { response, error in

                if let result = response {
                    debugPrint(result)
                    handleResponse(response: result)
                } else if let error = error {
                    debugPrint(error)
                }
            }
        }
    }

    func downloadFile(name: String, path: String, completion: DownloadedFileCompletion?) {
        let fileManager = FileManager.default
        let directoryURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let destURL = directoryURL.appendingPathComponent(name)
        debugPrint("Name: \(name)")
        let destination: (URL, HTTPURLResponse) -> URL = { temporaryURL, response in
            return destURL
        }

        DropboxClientsManager.authorizedClient?.files.download(path: path, overwrite: true, destination: destination)
            .response(queue: downloadQueue) { [weak self] response, error in
                if let response = response {
                    self?.files.append(response)
                    completion?(response)
                } else if error != nil {
                    completion?(nil)
                }
            }
            .progress { progressData in
                print(progressData)
            }
    }
}
