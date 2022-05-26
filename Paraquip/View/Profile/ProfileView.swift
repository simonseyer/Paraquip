//
//  ProfileView.swift
//  Paraquip
//
//  Created by Simon Seyer on 09.04.21.
//

import SwiftUI
import CoreData

struct ProfileView: View {

    @ObservedObject var profile: Profile
    @State private var newEquipment: Equipment?
    @State private var showWeightView = false
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.locale) var locale: Locale

    init(profile: Profile) {
        self.profile = profile
    }

    var body: some View {
        Group {
            if profile.allEquipment.isEmpty {
                ProfileEmptyView()
            } else {
                List {
                    ProfileSectionView(
                        title: "Paraglider",
                        icon: "paraglider",
                        equipment: profile.paraglider
                    )
                    ProfileSectionView(
                        title: "Harness",
                        icon: "harness",
                        equipment: profile.harnesses
                    )
                    ProfileSectionView(
                        title: "Reserve",
                        icon: "reserve",
                        equipment: profile.reserves
                    )
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(profile.profileName)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showWeightView = true
                } label: {
                    Image(systemName: "scalemass.fill")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        newEquipment = Paraglider.create(context: managedObjectContext)
                        profile.addToEquipment(newEquipment!)
                    }) {
                        Label("Paraglider", image: "paraglider")
                    }
                    Button(action: {
                        newEquipment = Harness.create(context: managedObjectContext)
                        profile.addToEquipment(newEquipment!)
                    }) {
                        Label("Harness", image: "harness")
                    }
                    Button(action: {
                        newEquipment = Reserve.create(context: managedObjectContext)
                        profile.addToEquipment(newEquipment!)
                    }) {
                        Label("Reserve", image: "reserve")
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(item: $newEquipment) { equipment in
            NavigationView {
                EditEquipmentView(equipment: equipment, locale: locale)
            }
        }
        .sheet(isPresented: $showWeightView) {
            NavigationView {
                ProfileWeightView(profile: profile)
                    .toolbar {
                        ToolbarItem(placement: .navigation) {
                            Button("Close") {
                                showWeightView = false
                            }
                        }
                    }
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            NavigationView {
                ProfileView(profile: CoreData.fakeProfile)
            }

            NavigationView {
                ProfileView(profile: Profile.create(context: CoreData.previewContext, name: "Empty"))
            }
        }
        .environment(\.locale, .init(identifier: "de"))
        .environment(\.managedObjectContext, CoreData.previewContext)
    }
}
