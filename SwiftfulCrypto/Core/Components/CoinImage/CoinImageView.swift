//
//  CoinImageView.swift
//  SwiftfulCrypto
//
//  Created by Farido on 11/09/2024.
//

import SwiftUI


struct CoinImageView: View {

    @StateObject var vm: CoinImageModelView

    init(coin: Coin) {
        _vm = StateObject(wrappedValue: CoinImageModelView(coin: coin))
    }

    var body: some View {
        ZStack {
            if let image = vm.image {
                 Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else if vm.isLoading {
                ProgressView()
            } else {
                Image(systemName: "questionmark")
                    .foregroundStyle(Color.theme.secondaryText)

            }
        }
    }
}

struct CoinImageView_Previews: PreviewProvider {
    static var previews: some View {
        CoinImageView(coin: DeveloperPreview.instance.coin)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
