//
//  CoinImageServices.swift
//  SwiftfulCrypto
//
//  Created by Farido on 11/09/2024.
//

import Foundation
import SwiftUI
import Combine

class CoinImageServices {

    @Published var image: UIImage? = nil
    private var imageSubscription: AnyCancellable?
    private let coin: Coin
    private let fileManager = LocalFileManger.instance
    private let folderName = "coin_images"
    private let imageName: String

    init(coin: Coin) {
        self.coin = coin
        self.imageName = coin.id
        getCoinImage() 
    }

    private func getCoinImage() {
        if let savedImage = fileManager.getImage(imageName: imageName , folderName: folderName) {
            image = savedImage
            print("Retrieved image form File Manger!")
        } else {
            downloadCoinImage()
            print("Downloading image now")
        }
    }

    private func downloadCoinImage() {
        guard let url = URL(string: coin.image) else {return}
        imageSubscription = NetworkingManger.download(url: url)
            .tryMap({ (data) -> UIImage? in
                return UIImage(data: data)
            })
            .sink(receiveCompletion: NetworkingManger.handleCompletion, receiveValue: { [weak self] (returnedImage) in
                guard let self = self else {return}
                guard let downloadedImage = returnedImage else {return}
                self.image = downloadedImage
                self.imageSubscription?.cancel()
                self.fileManager.saveImage(image: downloadedImage, imageName: self.imageName, folderName: self.folderName)
            })
    }
}
