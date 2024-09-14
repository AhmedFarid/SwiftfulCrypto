//
//  MarketDataServices.swift
//  SwiftfulCrypto
//
//  Created by Farido on 13/09/2024.
//

import Foundation
import Combine

class MarketDataServices {
    @Published var marketData: MarketDataModel? = nil

    var marketSubscription: AnyCancellable?

    init() {
        getMarketData()
    }

    func getMarketData() {
        guard let url = URL(string: "https://api.coingecko.com/api/v3/global") else {return}
        marketSubscription = NetworkingManger.download(url: url)
            .decode(type: GlobalData.self, decoder: JSONDecoder())
            .sink(receiveCompletion: NetworkingManger.handleCompletion, receiveValue: { [weak self] marketResponse in
                guard let self = self else {return}
                self.marketData = marketResponse.data
                self.marketSubscription?.cancel()
            })
    }
}
