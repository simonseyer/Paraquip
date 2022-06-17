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
    @State private var createEquipmentOperation: Operation<Equipment>?
    @State private var showWeightView = false
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.locale) var locale: Locale

    @SectionedFetchRequest
    private var equipment: SectionedFetchResults<Int16, Equipment>

    init(profile: Profile) {
        self.profile = profile
        _equipment = SectionedFetchRequest(
            sectionIdentifier: \Equipment.type,
            sortDescriptors: [
                SortDescriptor(\Equipment.type),
                SortDescriptor(\.brand),
                SortDescriptor(\.name)
            ],
            predicate: NSPredicate(format: "%@ IN %K", profile, #keyPath(Equipment.profiles))
        )
    }

    var body: some View {
        Group {
            if equipment.isEmpty {
                ProfileEmptyView()
            } else {
                List(equipment) { section in
                    Section {
                        ForEach(section) { equipment in
                            NavigationLink {
                                EquipmentView(equipment: equipment)
                            } label: {
                                EquipmentRow(equipment: equipment)
                            }
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                managedObjectContext.delete(section[index])
                            }
                            try! managedObjectContext.save()
                        }
                    } header: {
                        ProfileSectionHeader(equipmentType: section.id)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(profile.profileName)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    showWeightView = true
                } label: {
                    Image(systemName: "scalemass.fill")
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button(action: {
                        createEquipmentOperation(type: Paraglider.self)
                    }) {
                        Label("Paraglider", image: "paraglider")
                    }
                    Button(action: {
                        createEquipmentOperation(type: Harness.self)
                    }) {
                        Label("Harness", image: "harness")
                    }
                    Button(action: {
                        createEquipmentOperation(type: Reserve.self)
                    }) {
                        Label("Reserve", image: "reserve")
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(item: $createEquipmentOperation) { operation in
            NavigationView {
                EditEquipmentView(equipment: operation.object, locale: locale)
                    .environment(\.managedObjectContext, operation.childContext)
                    .onDisappear {
                        try? managedObjectContext.save()
                    }
            }
        }
        .interactiveDismissDisabled(true)
        .sheet(isPresented: $showWeightView) {
            NavigationView {
                ProfileWeightView(profile: profile)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Close") {
                                showWeightView = false
                            }
                        }
                    }
            }
        }
    }

    private func createEquipmentOperation(type: Equipment.Type) {
        let operation: Operation<Equipment> = Operation(withParentContext: managedObjectContext) { context in
            type.create(context: context)
        }
        operation.object(for: profile).addToEquipment(operation.object)
        createEquipmentOperation = operation
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
