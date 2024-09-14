//
//  DetailsViewModel.swift
//  SwiftfulCrypto
//
//  Created by Farido on 14/09/2024.
//

import Foundation
import Combine

class DetailsViewModel: ObservableObject {
    @Published var overViewStatistics: [Statistic] = []
    @Published var additionalStatistics: [Statistic] = []
    @Published var coinDetails: CoinDetail? = nil
    @Published var coin: Coin

    private let coinDetailsDataServices: CoinDetailsDataServices
    private var cancellable = Set<AnyCancellable>()

    init(coin: Coin) {
        self.coin = coin
        self.coinDetailsDataServices = CoinDetailsDataServices(coin: coin)
        addCoinDetailsSubscribers()
    }

    private func addCoinDetailsSubscribers() {
        coinDetailsDataServices.$coinDetails
            .combineLatest($coin)
            .map(mapDataToStatistics)
            .sink { [weak self] returnedArrays in
                guard let self = self else {return}
                self.overViewStatistics = returnedArrays.overView
                self.additionalStatistics = returnedArrays.additional
            }
            .store(in: &cancellable)
    }

    private func mapDataToStatistics(coinDetailsData: CoinDetail?, coinData: Coin) -> (overView: [Statistic], additional: [Statistic]) {
        return (createOverView(coinData: coinData), createAdditionalArray(coinDetailsData: coinDetailsData, coinData: coinData))
    }

    private func createOverView(coinData: Coin) -> [Statistic] {
        //overView
        let price = coinData.currentPrice.asCurrencyWith6Decimals()
        let pricePresentChange = coinData.priceChangePercentage24H
        let priceStat = Statistic(title: "Current Price", value: price, percentageChange: pricePresentChange)

        let marketCap = "$\(coinData.marketCap?.formattedWithAbbreviations() ?? "")"
        let marketCapPresentChange = coinData.marketCapChangePercentage24H
        let marketCapStat = Statistic(title: "Market Capitalization", value: marketCap, percentageChange: marketCapPresentChange)

        let rank = "\(coinData.rank)"
        let rankStat = Statistic(title: "Rank", value: rank)

        let volum = "$" + (coinData.totalVolume?.formattedWithAbbreviations() ?? "")
        let volumStat = Statistic(title: "Volum", value: volum)

        let overViewArray: [Statistic] = [priceStat, marketCapStat, rankStat, volumStat]
        return overViewArray
    }

    private func createAdditionalArray(coinDetailsData: CoinDetail?, coinData: Coin) -> [Statistic] {
        //additional
        let high = coinData.high24H?.asCurrencyWith6Decimals() ?? "n/a"
        let highStat = Statistic(title: "24h High", value: high)

        let low = coinData.low24H?.asCurrencyWith6Decimals() ?? "n/a"
        let lowStat = Statistic(title: "24h Low", value: low)

        let priceChange = coinData.priceChange24H?.asCurrencyWith6Decimals() ?? "n/a"
        let pricePresentChange = coinData.priceChangePercentage24H
        let priceChangeStat = Statistic(title: "24h Price Change", value: priceChange, percentageChange: pricePresentChange)

        let marketCapChange = "$" + (coinData.marketCapChange24H?.formattedWithAbbreviations() ?? "")
        let marketCapPresentChange = coinData.marketCapChangePercentage24H
        let marketCapChangeStat = Statistic(title: "24 Market Cap Change", value: marketCapChange, percentageChange: marketCapPresentChange)

        let blockTime = coinDetailsData?.blockTimeInMinutes ?? 0
        let blockTimeString = blockTime == 0 ? "n/a" : "\(blockTime)"
        let blockStat = Statistic(title: "Block Time", value: blockTimeString)

        let hashing = coinDetailsData?.hashingAlgorithm ?? "n/a"
        let hashingStat = Statistic(title: "Hashing Algorithm", value: hashing)

        let additionalArray: [Statistic] = [highStat, lowStat, priceChangeStat, marketCapChangeStat, blockStat, hashingStat]
        return additionalArray
    }
}
