//
//  ListIcon.swift
//  Paraquip
//
//  Created by Simon Seyer on 10.09.22.
//

import SwiftUI

struct ListIcon: View {

    let image: Image

    var body: some View {
        ZStack {
            RoundedRectangle(cornerSize: CGSize(width: 6, height: 6), style: .continuous)
                .foregroundColor(Color.accentColor)
                .frame(width: 30, height: 30)
            image
                .resizable()
                .scaledToFit()
                .foregroundColor(Color.white)
                .fontWeight(.bold)
                .frame(width: 14, height: 14)
        }
    }
}

struct ListIcon_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ListIcon(image: Image(systemName: "bell.fill"))
            ListIcon(image: Image(systemName: "plus"))
        }
    }
}
