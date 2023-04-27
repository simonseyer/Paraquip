//
//  WingLoadLegendView.swift
//  Paraquip
//
//  Created by Simon Seyer on 26.03.23.
//

import SwiftUI

struct WingLoadLegendView: View {

    let isCertifiedWingLoadAvailable: Bool
    let isRecommendedWingLoadAvailable: Bool

    @Binding var isCertifiedWingLoadVisible: Bool
    @Binding var isRecommendedWingLoadVisible: Bool
    @Binding var isWingClassIndicationVisible: Bool

    private let rangeLegend: [(String, LocalizedStringKey)] = [
        ("--", "Very low"),
        ("-", "Low"),
        ("o", "Middle"),
        ("+", "High"),
        ("++", "Very high")
    ]

    private var certifiedWingLoadIcon: Image {
        if isCertifiedWingLoadAvailable {
            if isCertifiedWingLoadVisible {
                return Image(systemName: "eye.fill")
            } else {
                return Image(systemName: "eye.slash.fill")
            }
        } else {
            return Image(systemName: "x.circle.fill")
        }
    }

    private var recommendedWingLoadIcon: Image {
        if isRecommendedWingLoadAvailable {
            if isRecommendedWingLoadVisible {
                return Image(systemName: "eye.fill")
            } else {
                return Image(systemName: "eye.slash.fill")
            }
        } else {
            return Image(systemName: "x.circle.fill")
        }
    }

    private var wingClassIndicationIcon: Image {
        if isWingClassIndicationVisible {
            return Image(systemName: "eye.fill")
        } else {
            return Image(systemName: "eye.slash.fill")
        }
    }

    private var certifiedWingLoadOpacity: Double {
        if isCertifiedWingLoadVisible && isCertifiedWingLoadAvailable {
            return 1.0
        } else {
            return 0.3
        }
    }

    private var recommendedWingLoadOpacity: Double {
        if isRecommendedWingLoadVisible {
            return 1.0
        } else {
            return 0.3
        }
    }

    private var wingClassIndicationOpacity: Double {
        if isWingClassIndicationVisible {
            return 1.0
        } else {
            return 0.3
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            Group {
                HStack {
                    DesiredWingLoadMarker()
                    Text("Desired wing load")
                }

                HStack {
                    CurrentWingLoadMarker()
                    Text("Current wing load")
                }

                HStack {
                    CertifiedWingLoadMarker(recommended: false)
                    Text("Certified weight range \(certifiedWingLoadIcon)")
                }
                .opacity(certifiedWingLoadOpacity)
                .onTapGesture {
                    withAnimation {
                        isCertifiedWingLoadVisible.toggle()
                    }
                }

                if isRecommendedWingLoadAvailable {
                    HStack {
                        CertifiedWingLoadMarker(recommended: true)
                        Text("Recommended weight range \(recommendedWingLoadIcon)")
                    }
                    .opacity(recommendedWingLoadOpacity)
                    .onTapGesture {
                        withAnimation {
                            isRecommendedWingLoadVisible.toggle()
                        }
                    }
                }

                HStack {
                    WingClassPill(text: Text("A"))
                    Text("Common wing load by EN-class \(wingClassIndicationIcon)")
                }
                .opacity(wingClassIndicationOpacity)
                .onTapGesture {
                    withAnimation {
                        isWingClassIndicationVisible.toggle()
                    }
                }

                HStack(spacing: 5) {
                    ForEach(rangeLegend, id: \.0) { range in
                        HStack(spacing: 2) {
                            Text(range.0).opacity(0.5)
                            Text(range.1)
                        }
                    }
                }
                .padding(.leading, 2)
            }
            .frame(height: 18)

            Divider()

            Text("wing_load_disclaimer")
        }
        .padding()
        .background(Color(uiColor:.secondarySystemGroupedBackground))
        .cornerRadius(6)
        .font(.caption)
    }
}

fileprivate struct CertifiedWingLoadMarker: View {

    let recommended: Bool

    var body: some View {
        Rectangle()
            .overlay(alignment: .trailing) {
                if !recommended {
                    VStack {
                        Spacer()
                        Image(systemName: "arrow.right")
                            .foregroundColor(.black)
                            .font(.system(size: 5, weight: .bold))
                            .padding(.bottom, 3)
                            .padding(.trailing, 1)
                    }
                }
            }
            .foregroundColor(Color(UIColor.systemOrange))
            .opacity(recommended ? 0.3 : 0.6)
            .frame(width: 10, height: 20)
            .padding(5)
    }
}

fileprivate struct DesiredWingLoadMarker: View {
    var body: some View {
        Circle()
            .strokeBorder(.tint, lineWidth: 2)
            .frame(width: 14, height: 14)
            .padding(3)
    }
}

fileprivate struct CurrentWingLoadMarker: View {
    var body: some View {
        Circle()
            .foregroundStyle(.tint)
            .frame(width: 10, height: 10)
            .padding(5)
    }
}

struct WingLoadLegendView_Previews: PreviewProvider {

    struct PreviewContainer: View {

        let isCertifiedWingLoadAvailable: Bool
        let isRecommendedWingLoadAvailable: Bool

        @State var isCertifiedWingLoadVisible: Bool = true
        @State var isRecommendedWingLoadVisible: Bool = true
        @State var isWingClassIndicationVisible: Bool = true

        @ViewBuilder
        var body: some View {
            WingLoadLegendView(
                isCertifiedWingLoadAvailable: isCertifiedWingLoadAvailable,
                isRecommendedWingLoadAvailable: isRecommendedWingLoadAvailable,
                isCertifiedWingLoadVisible: $isCertifiedWingLoadVisible,
                isRecommendedWingLoadVisible: $isRecommendedWingLoadVisible,
                isWingClassIndicationVisible: $isWingClassIndicationVisible)
        }
    }

    static var previews: some View {
        VStack {
            PreviewContainer(
                isCertifiedWingLoadAvailable: true,
                isRecommendedWingLoadAvailable: true
            )
            .padding()
            PreviewContainer(
                isCertifiedWingLoadAvailable: false,
                isRecommendedWingLoadAvailable: false
            )
            .padding()
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .tint(Color(uiColor: .systemYellow))
        .environment(\.locale, .init(identifier: "de"))
    }
}

