//
//  TagGridView.swift
//  PRChecker
//
//  Created by Chen Yuhan on 2021/11/14.
//

import SwiftUI

struct TagGridView: View {
    var tagViews: [TagView]

    @State private var totalHeight: CGFloat = 0

    // Ref: https://stackoverflow.com/questions/62102647/swiftui-hstack-with-wrap-and-dynamic-height
    var body: some View {
        var width: CGFloat = 0
        var height: CGFloat = 0

        VStack {
            GeometryReader { geometry in
                let containerWidth = geometry.size.width

                ZStack(alignment: .topLeading) {
                    ForEach(tagViews, id: \.text) { tagView in
                        tagView
                            .padding(4)
                            .alignmentGuide(.leading, computeValue: { d in
                                if (abs(width - d.width) > containerWidth) {
                                    width = 0
                                    height -= d.height
                                }
                                let result = width
                                if tagView == tagViews.last! {
                                    width = 0 // last item
                                } else {
                                    width -= d.width
                                }
                                return result
                            })
                            .alignmentGuide(.top, computeValue: { _ in
                                let result = height
                                if tagView == tagViews.last! {
                                    height = 0 // last item
                                }
                                return result
                            })
                    }
                }
                .background(viewHeightReader($totalHeight))
            }
        }
        .frame(height: totalHeight)
    }

    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
}
