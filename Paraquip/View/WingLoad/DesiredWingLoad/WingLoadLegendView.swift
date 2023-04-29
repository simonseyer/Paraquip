//
//  WingLoadLegendView.swift
//  Paraquip
//
//  Created by Simon Seyer on 26.03.23.
//

import SwiftUI

struct WingLoadLegendView: View {

    let isWingLoadAvailable: Bool
    let isWeightRangeAvailable: Bool

    @Binding var isWeightRangeVisible: Bool
    @Binding var isWingClassIndicationVisible: Bool

    private let rangeLegend: [(String, LocalizedStringKey)] = [
        ("--", "Very low"),
        ("-", "Low"),
        ("o", "Middle"),
        ("+", "High"),
        ("++", "Very high")
    ]

    private let unavailableIcon = Image(systemName: "x.circle.fill")
    private let visibleIcon = Image(systemName: "eye.fill")
    private let hiddenIcon = Image(systemName: "eye.slash.fill")
    private let visibleOpactity = 1.0
    private let hiddenOpacity = 0.3

    private var weightRangeIcon: Image {
        if isWeightRangeAvailable {
            if isWeightRangeVisible {
                return visibleIcon
            } else {
                return hiddenIcon
            }
        } else {
            return unavailableIcon
        }
    }

    private var wingClassIndicationIcon: Image {
        isWingClassIndicationVisible ? visibleIcon : hiddenIcon
    }

    private var weightRangeOpacity: Double {
        if isWeightRangeAvailable && isWeightRangeVisible { return visibleOpactity
        } else {
            return hiddenOpacity
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
                    if isWingLoadAvailable {
                        Text("Current wing load")
                    } else {
                        Text("Current wing load \(unavailableIcon)")
                    }

                }
                .opacity(isWingLoadAvailable ? visibleOpactity : hiddenOpacity)

                HStack {
                    CertifiedWingLoadMarker(recommended: false)
                    Text("Certified/recommended weight range \(weightRangeIcon)")
                }
                .opacity(weightRangeOpacity)
                .onTapGesture {
                    withAnimation {
                        isWeightRangeVisible.toggle()
                    }
                }

                HStack {
                    WingClassPill(text: Text("A"))
                    Text("Common wing load by EN-class \(wingClassIndicationIcon)")
                }
                .opacity(isWingClassIndicationVisible ? visibleOpactity : hiddenOpacity)
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

        let isWingLoadAvailable: Bool
        let isWeightRangeAvailable: Bool

        @State var isWeightRangeVisible: Bool = true
        @State var isWingClassIndicationVisible: Bool = true

        @ViewBuilder
        var body: some View {
            WingLoadLegendView(
                isWingLoadAvailable: isWingLoadAvailable,
                isWeightRangeAvailable: isWeightRangeAvailable,
                isWeightRangeVisible: $isWeightRangeVisible,
                isWingClassIndicationVisible: $isWingClassIndicationVisible)
        }
    }

    static var previews: some View {
        VStack {
            PreviewContainer(
                isWingLoadAvailable: true,
                isWeightRangeAvailable: true)
            .padding()
            PreviewContainer(
                isWingLoadAvailable: false,
                isWeightRangeAvailable: false)
            .padding()
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .tint(Color(uiColor: .systemYellow))
        .environment(\.locale, .init(identifier: "de"))
    }
}

