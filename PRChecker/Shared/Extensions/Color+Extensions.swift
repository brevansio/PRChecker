//
//  Color+Extensions.swift
//  PRChecker
//
//  Created by Chen Yuhan on 2021/11/06.
//

import SwiftUI

extension Color {
    // Ref: https://developer.apple.com/design/human-interface-guidelines/ios/visual-design/color/#dynamic-system-colors
    static let gray1 = Color("gray1")
    static let gray2 = Color("gray2")
    static let gray3 = Color("gray3")
    static let gray4 = Color("gray4")
    static let gray5 = Color("gray5")
    static let gray6 = Color("gray6")
    static let primaryBackground = Color("primaryBackground")
}

extension Color {
    init(hexValue: String) {
        let normalizedString = hexValue.trimmingCharacters(in: .init(charactersIn: "#")).uppercased()
        
        let hexValue = Int(normalizedString, radix: 16) ?? 0
        let red = (hexValue & 0xFF0000) >> 16
        let green = (hexValue & 0x00FF00) >> 8
        let blue = (hexValue & 0x0000FF)
        
        self.init(red: Double(red) / 255.0, green: Double(green) / 255.0, blue: Double(blue) / 255.0)
    }
}
