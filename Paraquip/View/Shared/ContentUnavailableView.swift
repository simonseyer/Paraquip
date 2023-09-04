//
//  ContentUnavailableView.swift
//  Paraquip
//
//  Created by Simon Seyer on 04.09.23.
//

import SwiftUI

struct ContentUnavailableView: View {

    let title: LocalizedStringKey
    let systemImage: String

    var body: some View {
        VStack {
            Image(systemName: systemImage)
                .font(.system(size: 48, weight: .semibold))
                .foregroundStyle(.secondary)
                .padding()
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
        }
    }
}

#Preview {
    ContentUnavailableView(title: "Test", systemImage: "tray.full.fill")
}
