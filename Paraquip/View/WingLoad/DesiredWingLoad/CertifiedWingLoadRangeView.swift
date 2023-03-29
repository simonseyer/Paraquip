//
//  CertifiedWingLoadRangeView.swift
//  Paraquip
//
//  Created by Simon Seyer on 29.03.23.
//

import SwiftUI

struct CertifiedWingLoadRangeView: View {

    let isLower: Bool

    @ViewBuilder
    var body: some View {
        Rectangle()
            .overlay(alignment: isLower ? .trailing : .leading) {
                arrowOverlay
            }
            .foregroundColor(Color(UIColor.systemOrange))
            .opacity(0.6)
    }

    @ViewBuilder
    private var arrowOverlay: some View {
        VStack {
            Spacer()
            Image(systemName: "arrow.\(isLower ? "right" : "left")")
                .foregroundColor(.black)
                .font(.system(size: 8, weight: .bold))
                .padding(.bottom, 10)
                .padding(isLower ? .trailing : .leading, 6)
        }
    }
}

struct CertifiedWingLoadRangeView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            CertifiedWingLoadRangeView(isLower: true)
            CertifiedWingLoadRangeView(isLower: false)
        }
        .frame(height: 100)
        .padding()
    }
}
