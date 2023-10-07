//
//  DesiredWingLoadView.swift
//  Paraquip
//
//  Created by Simon Seyer on 26.03.23.
//

import SwiftUI

struct DesiredWingLoadView: View {

    @ObservedObject var profile: Profile

    @State private var isWeightRangeVisible = true
    @State private var isWingClassIndicationVisible = true

    @FetchRequest
    private var equipment: FetchedResults<Equipment>

    private var isWeightRangeAvailable: Bool {
        guard let paraglider = profile.paraglider else {
            return false
        }
        return paraglider.projectedArea != nil && !paraglider.weightRanges.isEmpty
    }

    private var isRecommendedWeightRangeAvailable: Bool {
        profile.paraglider?.hasRecommendedWeightRange ?? false
    }

    init(profile: Profile) {
        self.profile = profile
        _equipment = FetchRequest(
            previewEntity: Equipment.previewEntity,
            sortDescriptors: Equipment.defaultSortDescriptors(),
            predicate: profile.equipmentPredicate
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Desired wing load")
                .font(.headline)
                .padding(.bottom)

            WingLoadGraphic(
                profile: profile,
                isWeightRangeVisible: isWeightRangeVisible,
                isWingClassIndicationVisible: isWingClassIndicationVisible
            )

            HStack(spacing: 2) {
                Slider(value: $profile.desiredWingLoadValue,
                       in: profile.visualizedWingLoadRange)
                    .padding(.trailing, 8)
                Text(profile.desiredWingLoadValue, format: .number.precision(.fractionLength(2)))
                    .monospacedDigit()
                Text("kg/m²")
            }
            .padding([.leading, .trailing], 6)
            .padding([.top, .bottom], 24)

            WingLoadLegendView(
                isWingLoadAvailable: profile.wingLoadValue != nil,
                isWeightRangeAvailable: isWeightRangeAvailable,
                isRecommendedWeightRangeAvailable: isRecommendedWeightRangeAvailable,
                isWeightRangeVisible: $isWeightRangeVisible,
                isWingClassIndicationVisible: $isWingClassIndicationVisible
            )
            .padding([.leading, .trailing], 6)
        }
        .padding([.leading, .trailing], 8)
        .padding([.top, .bottom])
        .background(Color(UIColor.systemGroupedBackground))
        .cornerRadius(6)
        .tint(Color(uiColor: .systemYellow))

        let _ = equipment // Required to observe equipment for (weight) changes
    }
}

#Preview {
    DesiredWingLoadView(profile: CoreData.fakeProfile)
        .padding()
        .environment(\.managedObjectContext, .preview)
}
