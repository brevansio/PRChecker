//
//  PRItemType.swift
//  PRChecker (iOS)
//
//  Created by Chen Yuhan on 2021/11/07.
//

import Foundation
import SwiftUI

enum PRItemType {
    case repositoryName
    case state
    case title
    case branch
    case author
    case changes
    case commits
    case description
    case tag
    case reviewStatus
    case readStatus
    case backwardArrow

    var image: Image? {
        guard let imageName: String = {
            switch self {
            case .repositoryName:
                return "square.stack.3d.down.right"
            case .state:
                return "exclamationmark.circle"
            case .branch:
                return "arrow.triangle.branch"
            case .author:
                return "person"
            case .changes:
                return "plus.slash.minus"
            case .commits:
                return "number.square"
            case .description:
                return "doc.text"
            case .tag:
                return "tag"
            case .reviewStatus:
                return "bell.badge"
            case .readStatus:
                return "envelope.open"
            case .backwardArrow:
                return "arrow.backward"
            default:
                return nil
            }
        }() else {
            return nil
        }

        return Image(systemName: imageName)
    }

    var foregroundColor: Color {
        switch self {
        case .state:
            return .gray6
        default:
            return .primary
        }
    }
}

enum BranchType {
    case origin
    case new

    var color: Color {
        switch self {
        case .origin:
            return .init(red: 0.8, green: 0.9, blue: 0.8)
        case .new:
            return .init(red: 0.7, green: 0.9, blue: 0.9)
        }
    }
}
