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
            .fontWeight(.medium)
            .aspectRatio(contentMode: .fit)
            .padding(10)
            .frame(width: 40, height: 40)
            .background(
                isSelected ? Color.accentColor :
                    Color(UIColor.systemGray5)
            )
            .foregroundColor(isSelected ? .white : .black)
            .cornerRadius(6)
    }
}

struct IconSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            IconSelectionView(icon: .default, isSelected: true)
            IconSelectionView(icon: .default, isSelected: false)
        }
    }
}
