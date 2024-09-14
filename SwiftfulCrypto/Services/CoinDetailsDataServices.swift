//
//  CoinDetailsDataServices.swift
//  SwiftfulCrypto
//
//  Created by Farido on 14/09/2024.
//

import Foundation
import Combine

class CoinDetailsDataServices {
    @Published var coinDetails: CoinDetail? = nil
    var coinDetailsSubscription: AnyCancellable?
    let coin: Coin

    init(coin: Coin) {
        self.coin = coin
        getCoinDetails()
    }

    func getCoinDetails() {
        guard let url = URL(string: "https://api.coingecko.com/api/v3/coins/\(coin.id)?localization=false&tickers=false&market_data=false&community_data=false&developer_data=false&sparkline=false") else {return}
        coinDetailsSubscription = NetworkingManger.download(url: url)
            .decode(type: CoinDetail.self, decoder: JSONDecoder())
            .sink(receiveCompletion: NetworkingManger.handleCompletion, receiveValue: { [weak self] (coinResponse) in
                guard let self = self else {return}
                self.coinDetails = coinResponse
                self.coinDetailsSubscription?.cancel()
            })
    }
}
