//
//  FileListViewController.swift
//  Media_viewer
//
//  Created by Arthur on 03.09.2023.
//

import UIKit
import AVKit

class FileListViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    private let spinner = UIActivityIndicatorView(style: .medium)

    var viewModel = FileListViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViewModel()
        self.getFiles()

        self.setupTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar()
    }

    private func setupViewModel() {
        self.viewModel.reloadTableView = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }

        self.viewModel.onInsertRows = { [weak self] (indexPaths) in
            DispatchQueue.main.async {
                self?.tableView.insertRows(at: indexPaths, with: .left)
            }
        }
    }

    private func getFiles() {
        self.spinner.startAnimating()
        self.viewModel.getFiles {
            DispatchQueue.main.async { [weak self] in
                self?.spinner.stopAnimating()
            }
        }
    }

    func popViewController(action: UIAlertAction) {
        self.navigationController?.popViewController(animated: true)
    }

    private func setupNavigationBar() {
        self.navigationController?.navigationBar.tintColor = .black
        self.title = "Files"
    }

    private func setupTableView() {
        self.spinner.color = UIColor.darkGray
        self.spinner.hidesWhenStopped = true
        self.tableView.tableFooterView = self.spinner
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(FileCell.nib, forCellReuseIdentifier: FileCell.identifier)
    }

    private func showImage(image: UIImage, from view: UIView) {
        let imageInfo   = GSImageInfo(image: image, imageMode: .aspectFit)
        let transitionInfo = GSTransitionInfo(fromView: view)
        let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)

        imageViewer.dismissCompletion = {
            print("dismissCompletion")
        }
        
        present(imageViewer, animated: true, completion: nil)
    }

    private func showVideo(url: URL) {
        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
}

// MARK: - UITableViewDataSource

extension FileListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.fileCellViewModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FileCell.identifier, for: indexPath) as? FileCell else {
            return UITableViewCell()
        }
        let cellVM = viewModel.getCellViewModel(at: indexPath)
        cell.setup(with: cellVM)
        return cell
    }
}

extension FileListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: false)
        guard let cell = self.tableView.cellForRow(at: indexPath) else { return }

        let viewModel = viewModel.getCellViewModel(at: indexPath)
        switch viewModel.type {
        case .image:
            self.showImage(image: viewModel.image, from: cell)
        case .video:
            self.showVideo(url: viewModel.url)
        }
    }
}

extension FileListViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard scrollView == tableView else { return }
        
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height)
        {
            self.getFiles()
        }
    }
}
