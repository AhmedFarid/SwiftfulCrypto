//
//  CoinImageViewModel.swift
//  SwiftfulCrypto
//
//  Created by Farido on 11/09/2024.
//

import Foundation
import SwiftUI
import Combine

class CoinImageModelView: ObservableObject {
    @Published var image: UIImage? = nil
    @Published var isLoading: Bool = false

    private let coin: Coin
    private let dataService: CoinImageServices
    private var cancellable = Set<AnyCancellable>()

    init(coin: Coin) {
        self.coin = coin
        self.dataService = CoinImageServices(coin: coin)
        self.addSubscribers()
        self.isLoading = true
    }

    private func addSubscribers() {
        dataService.$image
            .sink {[weak self] (_) in
                guard let self = self else {return}
                self.isLoading = false
            } receiveValue: {[weak self] returnedImage  in
                guard let self = self else {return}
                self.image = returnedImage
            }
            .store(in: &cancellable)
    }
}
