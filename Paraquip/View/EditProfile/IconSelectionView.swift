//
//  IconSelectionView.swift
//  Paraquip
//
//  Created by Simon Seyer on 16.06.22.
//

import SwiftUI

struct IconSelectionView: View {

    let icon: Profile.Icon
    let isSelected: Bool

    var body: some View {
        Image(systemName: icon.systemName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .padding(12)
            .frame(width: 55, height: 55)
            .background(
                isSelected ? Color.accentColor :
                    Color(UIColor.systemGray5)
            )
            .cornerRadius(10)
    }
}

struct IconSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        IconSelectionView(icon: .default, isSelected: true)
    }
}
