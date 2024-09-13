//
//  LocalFileManger.swift
//  SwiftfulCrypto
//
//  Created by Farido on 11/09/2024.
//

import Foundation
import SwiftUI

class LocalFileManger {
    static let instance = LocalFileManger()

    private init() {}

    func saveImage(image: UIImage, imageName: String, folderName: String) {
        // create folder
        createFolderIfNeeded(folderName: folderName)

        // get path for image
        guard
            let data = image.pngData(),
            let url = getURLForImage(imageName: imageName, folderName: folderName)
        else {return}

        // save image to path
        do {
            try data.write(to: url)
        } catch let error {
            print("Error in saving image ImageName: \(imageName). \(error)")
        }
    }

    func getImage(imageName: String, folderName: String) -> UIImage? {
        guard
            let url = getURLForImage(imageName: imageName, folderName: folderName),
            FileManager.default.fileExists(atPath: url.path(percentEncoded: true)) else {
            return nil
        }
        return UIImage(contentsOfFile: url.path(percentEncoded: true))
    }

    private func createFolderIfNeeded(folderName: String) {
        guard let url = getUrlForFolder(folderName: folderName) else {return}
        if !FileManager.default.fileExists(atPath: url.path(percentEncoded: true)) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
            } catch let error {
                print("Error in creating directory. FolderName: \(folderName). \(error)")
            }
        }
    }

    private func getUrlForFolder(folderName: String) -> URL? {
        guard let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {return nil}
        return url.appendingPathComponent(folderName)
    }

    private func getURLForImage(imageName: String, folderName: String) -> URL? {
        guard let folderURL = getUrlForFolder(folderName: folderName) else {return nil}
        return folderURL.appendingPathComponent(imageName + ".png")
    }
}
