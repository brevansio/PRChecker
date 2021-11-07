//
//  CheckBox.swift
//  PRChecker
//
//  Created by Chen Yuhan on 2021/11/06.
//

import SwiftUI

struct CheckBox: View {
    @ObservedObject var filter: Filter
    let font: Font
    let toggleAction: ((Bool) -> Void)?

    init(filter: Filter, font: Font = .body, toggleAction: ((Bool) -> Void)? = nil) {
        self.filter = filter
        self.font = font
        self.toggleAction = toggleAction
    }

    var body: some View {
        Button(action: toggle) {
            if filter.isEnabled {
                Image(systemName: "checkmark.square.fill")
                    .foregroundColor(.green)
            }
            else {
                Image(systemName: "square")
            }
            if let text = filter.name {
                Text(text)
            }
        }
        .font(font)
        .buttonStyle(PlainButtonStyle())
    }

    func toggle() -> Void {
        filter.isEnabled.toggle()
        toggleAction?(filter.isEnabled)
        // TODO: animation
    }
}

struct CheckBox_Previews: PreviewProvider {
    static var previews: some View {
        CheckBox(filter: Filter(name: "Test", filter: { _ in true }))
    }
}
