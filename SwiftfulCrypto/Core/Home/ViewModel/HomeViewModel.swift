//
//  HomeViewModel.swift
//  SwiftfulCrypto
//
//  Created by Farido on 11/09/2024.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject {

    @Published var statistics: [Statistic] = []
    @Published var allCoins: [Coin] = []
    @Published var portfolioCoins: [Coin] = []

    @Published var searchText: String = ""

    private let coinDataService = CoinDataService()
    private let marketDataService = MarketDataServices()
    private var cancellable = Set<AnyCancellable>()

    init() {
        addCoinSubscriber()
        addMarketSubscriber()
    }

    func addCoinSubscriber() {
        $searchText
            .combineLatest(coinDataService.$allCoins)
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .map(filterCoins)
            .sink { [weak self] returnedCoins in
                guard let self = self else {return}
                self.allCoins = returnedCoins
            }
            .store(in: &cancellable)
    }

    func addMarketSubscriber() {
        marketDataService.$marketData
            .map(mapGlobalMarketData)
            .sink { [weak self] returnStats in
                guard let self = self else {return}
                self.statistics = returnStats
            }
            .store(in: &cancellable)
    }

    private func filterCoins(text: String, coins: [Coin]) -> [Coin] {
        guard !text.isEmpty else {
            return coins
        }

        let lowercasedText = text.lowercased()

        return coins.filter { coin in
            return coin.name.lowercased().contains(lowercasedText) ||
            coin.symbol.lowercased().contains(lowercasedText) ||
            coin.id.lowercased().contains(lowercasedText)
        }
    }

    private func mapGlobalMarketData(marketDataModel: MarketDataModel?) -> [Statistic] {
        var states: [Statistic] = []
        guard let data = marketDataModel else {return states}

        let marketCap = Statistic(title: "Market Cap", value: data.marketCap, percentageChange: data.marketCapChangePercentage24HUsd)
        let volume = Statistic(title: "24h Volume", value: data.volume)
        let btcDominance = Statistic(title: "BTC Dominance", value: data.btcDominance)
        let portfolio = Statistic(title: "Portfolio Value", value: "$0.00", percentageChange: 0)

        states.append(contentsOf: [
            marketCap,
            volume,
            btcDominance,
            portfolio
        ])

        return states
    }
}
