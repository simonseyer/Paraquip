//
//  WingLoadView.swift
//  Paraquip
//
//  Created by Simon Seyer on 18.03.23.
//

import SwiftUI

struct WingLoadView: View {
    
    @ObservedObject var profile: Profile
    @FetchRequest private var equipment: FetchedResults<Equipment>
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.locale) var locale: Locale
    @State private var editEquipmentOperation: Operation<Equipment>?

    init(profile: Profile) {
        self.profile = profile
        _equipment = FetchRequest(
            previewEntity: Equipment.previewEntity,
            sortDescriptors: Equipment.defaultSortDescriptors(),
            predicate: profile.equipmentPredicate
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("wing_load_calculation")

                    WingLoadCalculationGraphic()

                    Text("wing_load_explanation")
                }
                .textSelection(.enabled)

                DesiredWingLoadView(profile: profile)
                    .padding([.leading, .trailing], -8)

                WingLoadGuidanceView()
            }
            .padding([.horizontal, .bottom], 30)

            let _ = equipment // Required to observe equipment for (weight) changes
        }
        .navigationBarTitle("Wing load")
    }
}

// MARK: Preview

private var noWingLoadProfile: Profile {
    let profile = Profile.create(context: .preview, name: "")
    let paraglider = Paraglider.create(context: .preview)
    paraglider.brandName = "Gin"
    paraglider.name = "Explorer 2"
    profile.addToEquipment(paraglider)
    return profile
}

#Preview {
    NavigationStack {
        WingLoadView(profile: CoreData.fakeProfile)
    }
    .environment(\.managedObjectContext, .preview)
}

#Preview("No Paraglider") {
    NavigationStack {
        WingLoadView(profile: Profile.create(context: .preview, name: "Empty"))
    }
    .environment(\.managedObjectContext, .preview)
}

#Preview("No Wing Load") {
    NavigationStack {
        WingLoadView(profile: noWingLoadProfile)
    }
    .environment(\.managedObjectContext, .preview)
}
