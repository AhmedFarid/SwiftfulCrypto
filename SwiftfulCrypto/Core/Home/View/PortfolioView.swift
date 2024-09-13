//
//  PortfolioView.swift
//  SwiftfulCrypto
//
//  Created by Farido on 13/09/2024.
//

import SwiftUI

struct PortfolioView: View {

    @EnvironmentObject private var vm: HomeViewModel
    @State private var selectedCoin: Coin? = nil
    @State private var qtyText: String = ""
    @State private var showCheckmark: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    SearchBarView(searchText: $vm.searchText)

                    coinLogoList
                    if selectedCoin != nil {
                        portfolioInputSection
                    }
                }
            }
            .navigationTitle("Edit Portfolio")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { XMarkButton() }

                ToolbarItem(placement: .topBarTrailing) {
                    trailingNavBarButton
                }
            }
        }
    }
}

extension PortfolioView {
    private var coinLogoList: some View {
        ScrollView(.horizontal, showsIndicators: false, content:  {
            LazyHStack(spacing: 10) {
                ForEach(vm.allCoins) { coin in
                    CoinLogoView(coin: coin)
                        .frame(width: 75)
                        .padding(4)
                        .onTapGesture {
                            withAnimation(.easeIn) {
                                selectedCoin = coin
                            }
                        }
                        .background (
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(selectedCoin?.id == coin.id ? Color.theme.green : Color.clear, lineWidth: 1)
                        )
                }
            }
            .frame(height: 120)
            .padding(.leading)
        })
    }

    private var portfolioInputSection: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Price Of \(selectedCoin?.symbol.uppercased() ?? ""):")
                Spacer()
                Text(selectedCoin?.currentPrice.asCurrencyWith6Decimals() ?? "")
            }
            Divider()
            HStack {
                Text("Amount holding:")
                Spacer()
                TextField("Ex.: 1.4", text: $qtyText)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.decimalPad)
            }
            Divider()
            HStack {
                Text("Current value:")
                Spacer()
                Text(getCurrentValue().asCurrencyWith2Decimals())
            }
        }
        .animation(.none)
        .padding()
        .font(.headline)
    }

    private func getCurrentValue() -> Double {
        if let quantity = Double(qtyText) {
            return quantity * (selectedCoin?.currentPrice ?? 0)
        }
        return 0.0
    }

    private var trailingNavBarButton: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark")
                .opacity(showCheckmark ? 1.0 : 0.0)

            Button(action: {
                saveButtonPressed()
            }, label: {
                Text("Save".uppercased())
            })
            .opacity(
                (selectedCoin != nil && selectedCoin?.currentHoldings != Double(qtyText)) ?
                1.0 : 0
            )

        }
        .font(.headline)
    }

    private func saveButtonPressed() {
        guard let coin = selectedCoin else { return }

        withAnimation(.easeIn) {
            showCheckmark = true
            removeSelectedCoin()
        }

        UIApplication.shared.endEditing()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeOut) {
                showCheckmark = false
            }
        }

    }

    private func removeSelectedCoin() {
        selectedCoin = nil
        vm.searchText = ""
    }
}

#Preview {
    PortfolioView()
        .environmentObject(DeveloperPreview.instance.homeVM)
}
