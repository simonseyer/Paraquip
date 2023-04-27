//
//  WingLoadGraphic.swift
//  Paraquip
//
//  Created by Simon Seyer on 26.03.23.
//

import SwiftUI

fileprivate struct WingLoadRange: Identifiable {
    let range: ClosedRange<Double>
    let text: LocalizedStringKey
    let opacity: Double

    var id: Int { range.hashValue }
}

struct WingLoadGraphic: View {

    let wingLoad: WingLoad
    let desiredWingLoad: Double

    let isCertifiedWingLoadVisible: Bool
    let isRecommendedWingLoadVisible: Bool
    let isWingClassIndicationVisible: Bool

    private var wingLoadRanges: [WingLoadRange] { [
        WingLoadRange(range: wingLoad.extendedRange.lowerBound...4.1, text: "--", opacity: 0.3),
        WingLoadRange(range: 4.1...4.3, text: "-", opacity: 0.7),
        WingLoadRange(range: 4.3...4.5, text: "o", opacity: 1.0),
        WingLoadRange(range: 4.5...4.7, text: "+", opacity: 0.7),
        WingLoadRange(range: 4.7...wingLoad.extendedRange.upperBound, text: "++", opacity: 0.3)
    ] }

    private let wingClassWingLoad: [(Text, Double)] = [
        (Text("A"), 4.0),
        (Text("\(Image(systemName: "arrow.down"))B"), 4.1),
        (Text("\(Image(systemName: "arrow.up"))B"), 4.3),
        (Text("C"), 4.6)
    ]

    private let height: Double = 46.0

    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geometry in
                HStack(alignment: .top, spacing: 0) {
                    ForEach(wingLoadRanges) { range in
                        Text(range.text)
                            .font(.caption2)
                            .frame(width: relativeWidth(of: range.range) * geometry.size.width)
                    }
                }
            }
            .padding(.bottom, 5)
            .opacity(0.5)

            ZStack(alignment: .top) {
                GeometryReader { geometry in
                    let width = geometry.size.width
                    HStack(alignment: .top, spacing: 0) {
                        ForEach(wingLoadRanges) { range in
                            Rectangle()
                                .foregroundColor(.accentColor.opacity(range.opacity))
                                .frame(
                                    width: relativeWidth(of: range.range) * width,
                                    height: height)
                        }
                    }

                    HStack(spacing: 0) {
                        if isCertifiedWingLoadVisible, let certifiedRange = wingLoad.certifiedRange {
                            CertifiedWingLoadRangeView(config: .certifiedLower)
                                .frame(
                                    width: width * relativeWidth(of: wingLoad.extendedRange.lowerBound...certifiedRange.lowerBound),
                                    height: height)
                        }

                        if isRecommendedWingLoadVisible, let certifiedRange = wingLoad.certifiedRange, let range = wingLoad.recommendedRange {
                            CertifiedWingLoadRangeView(config: .recommmended)
                                .frame(
                                    width: width * relativeWidth(of: certifiedRange.lowerBound...range.lowerBound),
                                    height: height)
                        }

                        Spacer()

                        if isRecommendedWingLoadVisible, let certifiedRange = wingLoad.certifiedRange, let range = wingLoad.recommendedRange {
                            CertifiedWingLoadRangeView(config: .recommmended)
                                .frame(
                                    width: width * relativeWidth(of: range.upperBound...certifiedRange.upperBound),
                                    height: height)
                        }

                        if isCertifiedWingLoadVisible, let certifiedRange = wingLoad.certifiedRange {
                            CertifiedWingLoadRangeView(config: .certifiedHigher)
                                .frame(
                                    width: width * relativeWidth(of: certifiedRange.upperBound...wingLoad.extendedRange.upperBound),
                                    height: height)
                        }
                    }

                    if isWingClassIndicationVisible {
                        ForEach(wingClassWingLoad, id: \.1) { wingClass in
                            WingClassPill(text: wingClass.0)
                                .position(
                                    x: width * relativePosition(of: wingClass.1),
                                    y: 13)
                        }
                    }

                    if let wingLoad = wingLoad.current {
                        Circle()
                            .foregroundStyle(.tint)
                            .frame(width: 10, height: 10)
                            .position(
                                x: geometry.size.width * relativePosition(of: wingLoad),
                                y: 32)
                    }

                    Circle()
                        .strokeBorder(.tint, lineWidth: 3)
                        .frame(width: 16, height: 16)
                        .position(
                            x: geometry.size.width * relativePosition(of: desiredWingLoad),
                            y: 32)
                }
            }
            .frame(height: height)
            .cornerRadius(6)

            WingLoadScale(range: wingLoad.extendedRange)
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    private func relativePosition(of load: Double) -> Double {
        (load - wingLoad.extendedRange.lowerBound) / (wingLoad.extendedRange.upperBound - wingLoad.extendedRange.lowerBound)
    }

    private func relativeWidth(of range: ClosedRange<Double>) -> Double {
        relativePosition(of: range.upperBound) - relativePosition(of: range.lowerBound)
    }
}

fileprivate extension WingLoad {
    init(tw: Double? = nil, pwa: Double? = nil, wr: ClosedRange<Double>? =  nil, rwr: ClosedRange<Double>? =  nil) {
        self.init(
            takeoffWeight: tw != nil ? .init(value: tw!, unit: .kilograms) : nil,
            projectedWingArea: pwa != nil ? .init(value: pwa!, unit: .squareMeters) : nil,
            wingWeightRange: wr != nil ? (.init(value: wr!.lowerBound, unit: .kilograms))...(.init(value: wr!.upperBound, unit: .kilograms)) :  nil,
            wingReconmmendedWeightRange: rwr != nil ? (.init(value: rwr!.lowerBound, unit: .kilograms))...(.init(value: rwr!.upperBound, unit: .kilograms)) :  nil
        )
    }
}

struct WingLoadGraphic_Previews: PreviewProvider {

    static let explorer2S = WingLoad(tw: 85, pwa: 20.43, wr: 75...95)

    static let previewData: [(String, WingLoad)] = [
        ("Gin Bolero 7 XXS", WingLoad(pwa: 18.83, wr: 55...80)),
        ("Gin Bolero 7 L", WingLoad(pwa: 26.95, wr: 100...130)),
        ("Gin Explorer 2 S", explorer2S),
        ("Gin Boomerang 12 XL", WingLoad(pwa: 23.16, wr: 120...137)),
        ("Gin Explorer 2 Underweight", WingLoad(tw: 45, pwa: 20.43, wr: 75...95)),
        ("Gin Explorer 2 Overweight", WingLoad(tw: 145, pwa: 20.43, wr: 75...95)),
    ]

    static let novaPreviewData: [(String, WingLoad)] = [
        ("Nova Prion 5 XXS", WingLoad(pwa: 18.50, wr: 55...75)),
        ("Nova Prion 5 XS", WingLoad(pwa: 20.9, wr: 65...85)),
        ("Nova Prion 5 S", WingLoad(pwa: 23, wr: 75...100)),
        ("Nova Prion 5 M", WingLoad(pwa: 25.3, wr: 90...115)),
        ("Nova Prion 5 L", WingLoad(pwa: 28.3, wr: 105...140)),
        ("Nova Mentor 7 XS", WingLoad(pwa: 19.8, wr: 70...95, rwr: 80...90)),
        ("Nova Mentor 7 S", WingLoad(pwa: 21.77, wr: 80...105, rwr: 90...100)),
        ("Nova Mentor 7 M", WingLoad(pwa: 23.72, wr: 90...115, rwr: 100...110)),
        ("Nova Xenon 17", WingLoad(pwa: 17.35, wr: 65...80)),
        ("Nova Xenon 18", WingLoad(pwa: 18.42, wr: 75...90)),
        ("Nova Xenon 20", WingLoad(pwa: 20.47, wr: 80...105)),
        ("Nova Xenon 22", WingLoad(pwa: 22.5, wr: 95...115)),
        ("Nova Bion 2 M", WingLoad(pwa: 31, wr: 90...200)),
        ("Nova Bion 2 L", WingLoad(pwa: 35, wr: 120...225)),
    ]

    static var previews: some View {
        ScrollView {
            VStack {
                Group {
                    ForEach(novaPreviewData, id: \.0) { data in
                        VStack {
                            Text(data.0).font(.headline)
                            WingLoadGraphic(
                                wingLoad: data.1,
                                desiredWingLoad: (data.1.certifiedRange!.lowerBound + data.1.certifiedRange!.upperBound) / 2,
                                isCertifiedWingLoadVisible: true,
                                isRecommendedWingLoadVisible: true,
                                isWingClassIndicationVisible: true
                            )
                        }
                    }

                    Divider()

                    WingLoadGraphic(
                        wingLoad: explorer2S,
                        desiredWingLoad: 4.16,
                        isCertifiedWingLoadVisible: false,
                        isRecommendedWingLoadVisible: false,
                        isWingClassIndicationVisible: false
                    )

                    WingLoadGraphic(
                        wingLoad: explorer2S,
                        desiredWingLoad: 4.14,
                        isCertifiedWingLoadVisible: true,
                        isRecommendedWingLoadVisible: false,
                        isWingClassIndicationVisible: true
                    )
                }
                .padding()
            }
        }.tint(Color(uiColor: .systemYellow))
    }
}
