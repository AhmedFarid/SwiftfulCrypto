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
    @Published var isLoading: Bool = false
    @Published var searchText: String = ""
    @Published var sortOption: SortOption = .holding

    private let coinDataService = CoinDataService()
    private let marketDataService = MarketDataServices()
    private let portfolioDataServices = PortfolioDataServices()
    private var cancellable = Set<AnyCancellable>()

    enum SortOption {
        case rank, rankReversed
        case holding, holdingReversed
        case price, priceReversed
    }

    init() {
        addCoinSubscriber()
        addMarketSubscriber()
        addPortfolioCoins()
    }

    func addCoinSubscriber() {
        $searchText
            .combineLatest(coinDataService.$allCoins, $sortOption)
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .map(filterAndSortCoins)
            .sink { [weak self] returnedCoins in
                guard let self = self else {return}
                self.allCoins = returnedCoins
            }
            .store(in: &cancellable)
    }

    func addMarketSubscriber() {
        marketDataService.$marketData
            .combineLatest($portfolioCoins)
            .map(mapGlobalMarketData)
            .sink { [weak self] returnStats in
                guard let self = self else {return}
                self.statistics = returnStats
            }
            .store(in: &cancellable)
    }

    func addPortfolioCoins() {
        $allCoins
            .combineLatest(portfolioDataServices.$savedEntities)
            .map(mapAllCoinToPortfolioCoins)
            .sink { [weak self] returnedCoins in
                guard let self = self else {return}
                self.portfolioCoins = self.sortPortfolioIfNeeded(coins: returnedCoins)
                self.isLoading = false
            }
            .store(in: &cancellable)
    }

    func updatePortfolio(coin: Coin, amount: Double) {
        portfolioDataServices.updatePortfolio(coin: coin, amount: amount)
    }

    func reloadData() {
        isLoading = true
        coinDataService.getCoins()
        marketDataService.getMarketData()
        HapticManger.notification(type: .success)
    }

    private func filterAndSortCoins(text: String, coins: [Coin], sort: SortOption) -> [Coin] {
        var updatedCoins = filterCoins(text: text, coins: coins)
        sortCoins(sort: sort, coins: &updatedCoins)
        return updatedCoins
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

    private func sortCoins(sort: SortOption, coins: inout [Coin]) {
        switch sort {
        case .rank, .holding:
            coins.sort(by: {$0.rank < $1.rank})
        case .rankReversed, .holdingReversed:
            coins.sort(by: {$0.rank > $1.rank})
        case .price:
            coins.sort(by: {$0.currentPrice > $1.currentPrice})
        case .priceReversed:
            coins.sort(by: {$0.currentPrice < $1.currentPrice})
        }
    }

    private func sortPortfolioIfNeeded(coins: [Coin]) -> [Coin] {
        switch sortOption {
        case .holding:
            return coins.sorted(by: {$0.currentHoldingsValue > $1.currentHoldingsValue})
        case .holdingReversed:
            return coins.sorted(by: {$0.currentHoldingsValue < $1.currentHoldingsValue})
        default:
            return coins
        }
    }

    private func mapAllCoinToPortfolioCoins(allCoin: [Coin], portfolioCoins: [ProtfolioEntity]) -> [Coin] {
        allCoin
            .compactMap { coin -> Coin? in
                guard let entity = portfolioCoins.first(where: {$0.coinID == coin.id}) else {
                    return nil
                }
                return coin.updateHoldings(amount: entity.amount)
            }
    }

    private func mapGlobalMarketData(marketDataModel: MarketDataModel?, portfolioCoins: [Coin]) -> [Statistic] {
        var states: [Statistic] = []
        guard let data = marketDataModel else {return states}

        let marketCap = Statistic(title: "Market Cap", value: data.marketCap, percentageChange: data.marketCapChangePercentage24HUsd)
        let volume = Statistic(title: "24h Volume", value: data.volume)
        let btcDominance = Statistic(title: "BTC Dominance", value: data.btcDominance)

        let portfolioValue = 
        portfolioCoins
            .map({$0.currentHoldingsValue})
            .reduce(0, +)

        let previousValue =
        portfolioCoins
            .map { coin -> Double in
                let currentValue = coin.currentHoldingsValue
                let presentChange = (coin.priceChangePercentage24H ?? 0.0) / 100
                let previousValue = currentValue / (1 + presentChange)
                return previousValue
            }
            .reduce(0, +)

        let percentageChange = ((portfolioValue - previousValue) / previousValue) * 100
        let portfolio = Statistic(title: "Portfolio Value", value: portfolioValue.asCurrencyWith2Decimals(), percentageChange: percentageChange)

        states.append(contentsOf: [
            marketCap,
            volume,
            btcDominance,
            portfolio
        ])

        return states
    }
}
