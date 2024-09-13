//
//  HomeView.swift
//  SwiftfulCrypto
//
//  Created by Farido on 10/09/2024.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject private var vm: HomeViewModel
    @State private var showPortfolio: Bool = false // animate right
    @State private var showPortfolioView: Bool = false //new sheet

    var body: some View {
        ZStack {
            // Background layer
            Color.theme.background
                .ignoresSafeArea()
                .sheet(isPresented: $showPortfolioView, content: {
                    PortfolioView()
                        .environmentObject(vm)
                })

            // Content layer
            VStack {
                homeHeader
                
                HomeStatsView(showPortfolio: $showPortfolio)

                SearchBarView(searchText: $vm.searchText)

                columnTitles

                if !showPortfolio {
                    allCoinsList
                        .transition(.move(edge: .leading))
                }

                if showPortfolio {
                    portfolioCoinsList
                        .transition(.move(edge: .trailing))
                }

                Spacer(minLength: 0)
            }
        }
    }
}

#Preview {
    NavigationView {
        HomeView()
            .toolbar(.automatic, for: .navigationBar)
    }
    .environmentObject(Preview.dev.homeVM)

}

extension HomeView {
    private var homeHeader: some View {
        HStack {
            CircleButtonView(iconName: showPortfolio ? "plus" : "info")
                .animation(.none, value: 0)
                .onTapGesture {
                    if showPortfolio {
                        showPortfolioView.toggle()
                    }
                }
                .background(
                    CircleButtonAnimationView(animate: $showPortfolio)
                )

            Spacer()
            Text(showPortfolio ? "Portfolio" : "Live Prices")
                .animation(.none)
                .font(.headline)
                .fontWeight(.heavy)
                .foregroundStyle(Color.theme.accent)

            Spacer()
            CircleButtonView(iconName: "chevron.right")
                .rotationEffect(Angle(degrees: showPortfolio ? 180 : 0), anchor: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .onTapGesture {
                    withAnimation(.spring()) {
                        showPortfolio.toggle()
                    }
                }
        }
        .padding(.horizontal)
    }
}

extension HomeView {
    private var allCoinsList: some View {
        List {
            ForEach(vm.allCoins) { coin in
                CoinRowView(coin: coin, showHoldingsColumn: false)
                    .listRowInsets(.init(top: 10, leading: 0, bottom: 10, trailing: 10))
            }
        }
        .listStyle(.plain)
    }
}

extension HomeView {
    private var portfolioCoinsList: some View {
        List {
            ForEach(vm.portfolioCoins) { coin in
                CoinRowView(coin: coin, showHoldingsColumn: true)
                    .listRowInsets(.init(top: 10, leading: 0, bottom: 10, trailing: 10))
            }
        }
        .listStyle(.plain)
    }
}

extension HomeView {
    private var columnTitles: some View {
        HStack {
            Text("Coin")
            Spacer()
            if showPortfolio {
                Text("Holdings")
            }
            Text("Price")
                .frame(width: UIScreen.main.bounds.width / 2.9, alignment: .trailing)
        }
        .font(.caption)
        .foregroundStyle(Color.theme.secondaryText)
        .padding(.horizontal)

    }
}
