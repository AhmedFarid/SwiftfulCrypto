//
//  XMarkButton.swift
//  SwiftfulCrypto
//
//  Created by Farido on 13/09/2024.
//

import SwiftUI

struct XMarkButton: View {

    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Button {
            dismiss.callAsFunction()
        } label: {
            Image(systemName: "xmark")
                .font(.headline)
        }
    }
}

#Preview {
    XMarkButton()
}
