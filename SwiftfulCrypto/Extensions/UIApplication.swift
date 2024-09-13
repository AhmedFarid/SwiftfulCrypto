//
//  UIApplication.swift
//  SwiftfulCrypto
//
//  Created by Farido on 11/09/2024.
//

import Foundation
import SwiftUI

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
