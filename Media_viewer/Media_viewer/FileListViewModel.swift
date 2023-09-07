//
//  FileListViewModel.swift
//  Media_viewer
//
//  Created by Arthur on 03.09.2023.
//

import UIKit
import UniformTypeIdentifiers
import AVFoundation
import SwiftyDropbox

typealias Completion = (() -> Void)
typealias URLCompletion = ((URL)->Void)
typealias IndexPathCompletion = (([IndexPath]) -> Void)

enum FileType {
    case image
    case video
}

struct FileCellViewModel {
    let image: UIImage
    let url: URL
    let name: String

    let type: FileType
}

class FileListViewModel {
    var reloadTableView: Completion?
    var onInsertRows: IndexPathCompletion?

    var fileCellViewModels = [FileCellViewModel]()

    func getFiles(with completion: Completion?) {
        guard !DropBoxManager.shared.isMaxCount else {
            completion?()
            self.fileCellViewModels = DropBoxManager.shared.files.compactMap {
                guard let cellVM = createViewModel(result: $0) else { return nil }
                return cellVM
            }
            return
        }
    
        func createViewModel(result: (Files.FileMetadata, URL)) -> FileCellViewModel? {
            guard let data = try? Data(contentsOf: result.1) else { return nil }
            let fileURL = result.1

            if fileURL.containsImage, let image = UIImage(data: data) {
                let cellVM = FileCellViewModel(image: image,
                                               url: fileURL,
                                               name: result.0.name,
                                               type: .image)
                return cellVM
            }

            if fileURL.containsMovie || fileURL.containsMovie {
                let cellVM = FileCellViewModel(image: self.generateThumbnail(url: fileURL) ?? UIImage(),
                                               url: fileURL,
                                               name: result.0.name,
                                               type: .video)
                return cellVM
            }
            return nil
        }

        DropBoxManager.shared.downloadFiles { [weak self] result in
            completion?()
            guard let `self` = self,
                  let result = result,
                  let cellVM = createViewModel(result: result) else { return }
            
            addViewModel(cellVM: cellVM)
        }
    }

    func addViewModel(cellVM: FileCellViewModel) {
        self.fileCellViewModels.append(cellVM)
        let indexPaths = [IndexPath(row: fileCellViewModels.count - 1, section: 0)]
        self.onInsertRows?(indexPaths)
    }

    private func generateThumbnail(url: URL) -> UIImage? {
        do {
            let asset = AVURLAsset(url: url, options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)

            let uiImage = UIImage(cgImage: cgImage)
            return uiImage

        } catch let error {
            debugPrint(error)
            return nil
        }
    }

    func getCellViewModel(at indexPath: IndexPath) -> FileCellViewModel {
        return fileCellViewModels[indexPath.row]
    }
}
