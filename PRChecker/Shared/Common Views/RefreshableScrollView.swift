//
//  RefreshableScrollView.swift
//  PRChecker
//
//  Created by Bruce Evans on 2021/11/07.
//

import SwiftUI

private enum PositionType {
    case fixed, moving
}

private struct Position: Equatable {
    let type: PositionType
    let y: CGFloat
}

private struct PositionPreferenceKey: PreferenceKey {
    typealias Value = [Position]
    
    static var defaultValue = [Position]()
    
    static func reduce(value: inout [Position], nextValue: () -> [Position]) {
        value.append(contentsOf: nextValue())
    }
}

private struct PositionIndicator: View {
    let type: PositionType
    
    var body: some View {
        GeometryReader { geometry in
            Color.clear
                .preference(key: PositionPreferenceKey.self, value: [Position(type: type, y: geometry.frame(in: .global).minY)])
        }
    }
}

private let PullThreshold: CGFloat = 35.0

private enum RefreshState {
    case waiting, primed, loading
}

struct RefreshableScrollView<Content: View>: View {
    let onRefresh: (@escaping () -> Void) -> Void
    let content: Content
    
    @State private var state = RefreshState.waiting
    
    init(onRefresh: @escaping (@escaping () -> Void) -> Void, @ViewBuilder content: () -> Content) {
        self.onRefresh = onRefresh
        self.content = content()
    }
    
    var body: some View {
        ScrollView {
            ZStack(alignment: .top) {
                PositionIndicator(type: .moving)
                    .frame(height: 0)
                
                content
                    .alignmentGuide(.top) { _ in
                        state == .loading ? -PullThreshold : 0
                    }
                
                ZStack {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(height: PullThreshold)
                    if state == .loading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    }
                }
                .offset(y: state == .loading ? 0 : -PullThreshold)
            }
        }
        .background(PositionIndicator(type: .fixed))
        .onPreferenceChange(PositionPreferenceKey.self) { values in
            guard state != .loading else { return }
            
            DispatchQueue.main.async {
                let movingY = values.first { $0.type == .moving }?.y ?? 0
                let fixedY = values.first { $0.type == .fixed }?.y ?? 0
                let offset = movingY - fixedY
                
                if offset > PullThreshold && state == .waiting {
                    state = .primed
                } else if offset < PullThreshold && state == .primed {
                    state = .loading
                    onRefresh {
                        withAnimation {
                            self.state = .waiting
                        }
                    }
                }
            }
        }
    }
}
