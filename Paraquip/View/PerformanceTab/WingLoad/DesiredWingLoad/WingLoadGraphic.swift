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

    @ObservedObject var profile: Profile
    @FetchRequest private var equipment: FetchedResults<Equipment>

    let isWeightRangeVisible: Bool
    let isWingClassIndicationVisible: Bool

    private var wingLoadRanges: [WingLoadRange] { [
        WingLoadRange(range: profile.visualizedWingLoadRange.lowerBound...4.1, text: "--", opacity: 0.3),
        WingLoadRange(range: 4.1...4.3, text: "-", opacity: 0.7),
        WingLoadRange(range: 4.3...4.5, text: "o", opacity: 1.0),
        WingLoadRange(range: 4.5...4.7, text: "+", opacity: 0.7),
        WingLoadRange(range: 4.7...profile.visualizedWingLoadRange.upperBound, text: "++", opacity: 0.3)
    ] }

    private let wingClassWingLoad: [(Text, Double)] = [
        (Text("A"), 4.0),
        (Text("\(Image(systemName: "arrow.down"))B"), 4.1),
        (Text("\(Image(systemName: "arrow.up"))B"), 4.3),
        (Text("C"), 4.6)
    ]

    private let height: Double = 46.0

    init(profile: Profile, isWeightRangeVisible: Bool, isWingClassIndicationVisible: Bool) {
        self.profile = profile
        self.isWeightRangeVisible = isWeightRangeVisible
        self.isWingClassIndicationVisible = isWingClassIndicationVisible
        _equipment = FetchRequest(
            previewEntity: Equipment.previewEntity,
            sortDescriptors: Equipment.defaultSortDescriptors(),
            predicate: profile.equipmentPredicate
        )
    }

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
                                .foregroundStyle(.accent.opacity(range.opacity))
                                .frame(width: relativeWidth(of: range.range) * width)
                        }
                    }

                    if let paraglider = profile.paraglider,
                       let visibleWeightRange = profile.visualizedWeightRange {
                        WeightRangeGraphic(
                            equipment: paraglider,
                            visibleWeightRange: visibleWeightRange
                        )
                        .opacity(isWeightRangeVisible ? 1 : 0)
                    }

                    ForEach(wingClassWingLoad, id: \.1) { wingClass in
                        WingClassPill(text: wingClass.0)
                            .position(
                                x: width * relativePosition(of: wingClass.1),
                                y: 13)
                            .opacity(isWingClassIndicationVisible ? 1 : 0)
                    }

                    if let wingLoad = profile.wingLoadValue {
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
                            x: geometry.size.width * relativePosition(of: profile.desiredWingLoadValue),
                            y: 32)
                }
            }
            .frame(height: height)
            .cornerRadius(6)

            WingLoadScale(range: profile.visualizedWingLoadRange)

            let _ = equipment // Required to observe equipment for (weight) changes
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    private func relativePosition(of load: Double) -> Double {
        let lower = profile.visualizedWingLoadRange.lowerBound
        let upper = profile.visualizedWingLoadRange.upperBound
        return (load - lower) / (upper - lower)
    }

    private func relativeWidth(of range: ClosedRange<Double>) -> Double {
        relativePosition(of: range.upperBound) - relativePosition(of: range.lowerBound)
    }
}

struct WingLoadGraphic_Previews: PreviewProvider {

    static let explorer2S = profile(tw: 85, pwa: 20.43, wr: 75...95, dwl: 4.16)
    static let explorer2S2 = profile(tw: 85, pwa: 20.43, wr: 75...95, dwl: 4.14)

    static let previewData: [(String, Profile)] = [
        ("Gin Bolero 7 XXS", profile(pwa: 18.83, wr: 55...80)),
        ("Gin Bolero 7 L", profile(pwa: 26.95, wr: 100...130)),
        ("Gin Explorer 2 S", explorer2S),
        ("Gin Boomerang 12 XL", profile(pwa: 23.16, wr: 120...137)),
        ("Gin Explorer 2 Underweight", profile(tw: 45, pwa: 20.43, wr: 75...95)),
        ("Gin Explorer 2 Overweight", profile(tw: 145, pwa: 20.43, wr: 75...95)),
    ]

    static let novaPreviewData: [(String, Profile)] = [
        ("Nova Prion 5 XXS", profile(pwa: 18.50, wr: 55...75)),
        ("Nova Prion 5 XS", profile(pwa: 20.9, wr: 65...85)),
        ("Nova Prion 5 S", profile(pwa: 23, wr: 75...100)),
        ("Nova Prion 5 M", profile(pwa: 25.3, wr: 90...115)),
        ("Nova Prion 5 L", profile(pwa: 28.3, wr: 105...140)),
        ("Nova Mentor 7 XS", profile(pwa: 19.8, wr: 70...95, rwr: 80...90)),
        ("Nova Mentor 7 S", profile(pwa: 21.77, wr: 80...105, rwr: 90...100)),
        ("Nova Mentor 7 M", profile(pwa: 23.72, wr: 90...115, rwr: 100...110)),
        ("Nova Xenon 17", profile(pwa: 17.35, wr: 65...80)),
        ("Nova Xenon 18", profile(pwa: 18.42, wr: 75...90)),
        ("Nova Xenon 20", profile(pwa: 20.47, wr: 80...105)),
        ("Nova Xenon 22", profile(pwa: 22.5, wr: 95...115)),
        ("Nova Bion 2 M", profile(pwa: 31, wr: 90...200)),
        ("Nova Bion 2 L", profile(pwa: 35, wr: 120...225)),
    ]

    static var previews: some View {
        ScrollView {
            VStack {
                Group {
                    ForEach(novaPreviewData, id: \.0) { data in
                        VStack {
                            Text(data.0).font(.headline)
                            WingLoadGraphic(
                                profile: data.1,
                                isWeightRangeVisible: true,
                                isWingClassIndicationVisible: true
                            )
                        }
                    }

                    Divider()

                    WingLoadGraphic(
                        profile: explorer2S,
                        isWeightRangeVisible: false,
                        isWingClassIndicationVisible: false
                    )

                    WingLoadGraphic(
                        profile: explorer2S2,
                        isWeightRangeVisible: true,
                        isWingClassIndicationVisible: true
                    )
                }
                .padding()
            }
        }.tint(Color(uiColor: .systemYellow))
    }

    private static func profile(tw: Double? = nil, pwa: Double? = nil, wr: ClosedRange<Double>? =  nil, rwr: ClosedRange<Double>? = nil, dwl: Double? = nil) -> Profile {
        let profile = Profile.create(context: .preview)
        profile.pilotWeight = tw ?? 0
        profile.additionalWeight = 0
        let paraglider = Paraglider.create(context: .preview)

        if let pwa {
            paraglider.projectedAreaValue = pwa
        }
        if let wr {
            paraglider.minWeightValue = wr.lowerBound
            paraglider.maxWeightValue = wr.upperBound
        }
        if let rwr {
            paraglider.minRecommendedWeightValue = rwr.lowerBound
            paraglider.maxRecommendedWeightValue = rwr.upperBound
        }
        if let dwl {
            profile.desiredWingLoadValue = dwl
        }

        profile.addToEquipment(paraglider)
        return profile
    }
}
