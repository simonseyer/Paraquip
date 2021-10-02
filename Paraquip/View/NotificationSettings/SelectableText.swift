//
//  SelectableText.swift
//  Paraquip
//
//  Created by Simon Seyer on 16.05.21.
//

import SwiftUI

struct SelectableText<T: StringProtocol>: View {

    let text: T

    @Binding var isSelected: Bool

    var body: some View {
        Button(action: { isSelected.toggle() }) {
            Text(text)
        }
        .padding(EdgeInsets(top: 5,
                            leading: 14,
                            bottom: 5,
                            trailing: 14))
        .buttonStyle(PlainButtonStyle())
        .background(Color(UIColor.systemGray6))
        .cornerRadius(6)
        .foregroundColor(isSelected ? .accentColor : nil)
        .overlay(isSelected ? overlay : nil)
        .animation(.none, value: isSelected)
    }

    private var overlay: some View {
        RoundedRectangle(cornerRadius: 6)
            .stroke(Color.accentColor, lineWidth: 1)
    }
}

struct SelectableText_Previews: PreviewProvider {

    @State static var isSelected = false
    @State static var isSelectedI = true

    static var previews: some View {
        Group {
            SelectableText(text: "Test", isSelected: $isSelected)
            SelectableText(text: "Long test", isSelected: $isSelectedI)
        }
        .padding(30)
        .previewLayout(.sizeThatFits)
    }
}
