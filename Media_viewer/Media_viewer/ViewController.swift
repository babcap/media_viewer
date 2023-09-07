//
//  ViewController.swift
//  Media_viewer
//
//  Created by Arthur on 01.09.2023.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        self.setupObservers()
    }

    private func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(openFilesList), name: DropBoxManager.shared.loginNotificationName, object: nil)
    }

    @objc private func openFilesList() {
        guard let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "FileListViewController") as? FileListViewController else { return }
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func onButtonPressed(_ sender: Any) {
        DropBoxManager.shared.showAutorization(from: self)
    }
    
}

