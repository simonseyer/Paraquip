//
//  FormIcon.swift
//  Paraquip
//
//  Created by Simon Seyer on 22.08.21.
//

import SwiftUI

struct FormIcon: View {

    let icon: Image

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .foregroundColor(Color.accentColor)
            icon
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(6)
                .foregroundColor(.white)
        }
        .frame(width: 30, height: 30)
    }
}

struct FormIcon_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FormIcon(icon: Image(systemName: "book.fill"))
            FormIcon(icon: Image(systemName: "checkmark"))
        }
        .previewLayout(.sizeThatFits)

    }
}
