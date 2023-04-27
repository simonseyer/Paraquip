//
//  CertifiedWingLoadRangeView.swift
//  Paraquip
//
//  Created by Simon Seyer on 29.03.23.
//

import SwiftUI

struct CertifiedWingLoadRangeView: View {

    enum Configuration {
        case certifiedLower, certifiedHigher, recommmended
    }

    let config: Configuration

    private var isLower: Bool {
        config == .certifiedLower
    }

    @ViewBuilder
    var body: some View {
        Rectangle()
            .overlay(alignment: isLower ? .trailing : .leading) {
                if config != .recommmended {
                    arrowOverlay
                }
            }
            .foregroundColor(Color(UIColor.systemOrange))
            .opacity(config == .recommmended ? 0.3 : 0.6)
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
            CertifiedWingLoadRangeView(config: .certifiedLower)
            CertifiedWingLoadRangeView(config: .certifiedHigher)
        }
        .frame(height: 100)
        .padding()
    }
}
