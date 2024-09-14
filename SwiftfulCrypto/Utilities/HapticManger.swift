//
//  HapticManger.swift
//  SwiftfulCrypto
//
//  Created by Farido on 14/09/2024.
//

import Foundation
import SwiftUI

class HapticManger {
    static private let generator = UINotificationFeedbackGenerator()

    static func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        generator.notificationOccurred(type)
    }
}
