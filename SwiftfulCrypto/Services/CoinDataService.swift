//
//  CoinDataService.swift
//  SwiftfulCrypto
//
//  Created by Farido on 11/09/2024.
//

import Foundation
import Combine

class CoinDataService {
    @Published var allCoins: [Coin] = []
    var coinSubscription: AnyCancellable?

    init() {
        getCoins()
    }

    private func getCoins() {
        guard let url = URL(string: "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=250&page=1&sparkline=true&price_change_percentage=24h") else {return}
        coinSubscription = NetworkingManger.download(url: url)
            .decode(type: [Coin].self, decoder: JSONDecoder())
            .sink(receiveCompletion: NetworkingManger.handleCompletion, receiveValue: { [weak self] (coinResponse) in
                guard let self = self else {return}
                self.allCoins = coinResponse
                self.coinSubscription?.cancel()
            })
    }
}
