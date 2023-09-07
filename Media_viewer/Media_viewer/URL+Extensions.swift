//
//  URL+Extensions.swift
//  Media_viewer
//
//  Created by Arthur on 05.09.2023.
//

import UniformTypeIdentifiers

extension URL {
    func mimeType() -> String {
        let pathExtension = self.pathExtension
        if let type = UTType(filenameExtension: pathExtension) {
            if let mimetype = type.preferredMIMEType {
                return mimetype as String
            }
        }
        return "application/octet-stream"
    }

    var containsImage: Bool {
        let mimeType = self.mimeType()
        if let type = UTType(mimeType: mimeType) {
            return type.conforms(to: .image)
        }
        return false
    }

    var containsMovie: Bool {
        let mimeType = self.mimeType()
        if let type = UTType(mimeType: mimeType) {
            return type.conforms(to: .movie)   // ex. .mp4-movies
        }
        return false
    }

    var containsVideo: Bool {
        let mimeType = self.mimeType()
        if let type = UTType(mimeType: mimeType) {
            return type.conforms(to: .video)
        }
        return false
    }
}
