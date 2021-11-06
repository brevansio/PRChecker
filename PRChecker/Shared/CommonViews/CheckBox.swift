//
//  CheckBox.swift
//  PRChecker
//
//  Created by Chen Yuhan on 2021/11/06.
//

import SwiftUI

struct CheckBox: View {
    let text: String?
    let font: Font

    @State private var isChecked = false

    init(text: String?, font: Font = .body) {
        self.text = text
        self.font = font
    }

    var body: some View {
        Button(action: toggle) {
            if isChecked {
                Image(systemName: "checkmark.square.fill")
                    .foregroundColor(.green)
            }
            else {
                Image(systemName: "square")
            }
            if let text = text {
                Text(text)
            }
        }
        .font(font)
        .buttonStyle(PlainButtonStyle())
    }

    func toggle() -> Void {
        isChecked.toggle()
        // TODO: animation
    }
}

struct CheckBox_Previews: PreviewProvider {
    static var previews: some View {
        CheckBox(text: "hello")
    }
}
