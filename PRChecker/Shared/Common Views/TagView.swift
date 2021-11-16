//
//  TagView.swift
//  PRChecker
//
//  Created by Chen Yuhan on 2021/11/07.
//

import SwiftUI

struct TagView: View {
    let text: String
    let foregroundColor: Color
    let backgroundColor: Color

    init(
        text: String,
        foregroundColor: Color = .black,
        backgroundColor: Color
    ) {
        self.text = text
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
    }

    var body: some View {
        HStack {
            Text(text)
                .font(.body)
                .padding(4)
                .foregroundColor(foregroundColor)
                .background(backgroundColor)
                .cornerRadius(8)
        }
    }
}

extension TagView: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(text)
    }
}
