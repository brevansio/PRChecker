//
//  PRItemLabel.swift
//  PRChecker
//
//  Created by Chen Yuhan on 2021/11/07.
//

import SwiftUI

struct PRItemLabel: View {
    struct Style: LabelStyle {
        let type: PRItemType

        func makeBody(configuration: Self.Configuration) -> some View {
            Label {
                configuration.title
            } icon: {
                configuration.icon
                    .scaledToFit()
            }
            .font(.body)
            .foregroundColor(type.foregroundColor)
        }
    }

    let text: String
    let type: PRItemType

    var body: some View {
        Label {
            Text(text)
        } icon: {
            type.image
        }
        .labelStyle(Style(type: type))
    }
}
