//
//  DesiredWingLoadView.swift
//  Paraquip
//
//  Created by Simon Seyer on 26.03.23.
//

import SwiftUI

struct DesiredWingLoadView: View {

    @ObservedObject var profile: Profile
    let wingLoad: WingLoad

    @State private var isCertifiedWingLoadVisible = true
    @State private var isWingClassIndicationVisible = true

    @FetchRequest
    private var equipment: FetchedResults<Equipment>

    init(profile: Profile, wingLoad: WingLoad) {
        self.profile = profile
        self.wingLoad = wingLoad
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
                wingLoad: wingLoad,
                desiredWingLoad: profile.desiredWingLoad,
                isCertifiedWingLoadVisible: isCertifiedWingLoadVisible,
                isWingClassIndicationVisible: isWingClassIndicationVisible
            )

            HStack(spacing: 2) {
                Slider(value: $profile.desiredWingLoad,
                       in: wingLoad.extendedRange)
                    .padding(.trailing, 8)
                Text(profile.desiredWingLoad, format: .number.precision(.fractionLength(2)))
                    .monospacedDigit()
                Text("kg/m²")
            }
            .padding([.leading, .trailing], 6)
            .padding([.top, .bottom], 24)

            WingLoadLegendView(
                isCertifiedWingLoadAvailable: wingLoad.certifiedRange != nil,
                isCertifiedWingLoadVisible: $isCertifiedWingLoadVisible,
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

struct DesiredWingLoadView_Previews: PreviewProvider {
    static var previews: some View {
        DesiredWingLoadView(
            profile: CoreData.fakeProfile,
            wingLoad: CoreData.fakeProfile.wingLoad
        )
        .padding()
        .environment(\.managedObjectContext, CoreData.previewContext)
    }
}
