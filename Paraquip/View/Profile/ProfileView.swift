//
//  ProfileView.swift
//  Paraquip
//
//  Created by Simon Seyer on 09.04.21.
//

import SwiftUI
import CoreData

struct ProfileView: View {

    let profile: Profile?
    @State private var createEquipmentOperation: Operation<Equipment>?
    @State private var showWeightView = false
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.locale) var locale: Locale

    @SectionedFetchRequest
    private var equipment: SectionedFetchResults<Int16, Equipment>
    
    private var title: String {
        profile?.profileName ?? NSLocalizedString( "All Equipment", comment: "")
    }

    init(profile: Profile?) {
        self.profile = profile
        if ProcessInfo.isPreview {
            _equipment = SectionedFetchRequest(
                entity: NSEntityDescription.entity(forEntityName: "Equipment", in: CoreData.previewContext)!,
                sectionIdentifier: \Equipment.type,
                sortDescriptors: [
                    NSSortDescriptor(key: "type", ascending: true),
                    NSSortDescriptor(key: "brand", ascending: true),
                    NSSortDescriptor(key: "name", ascending: true)
                ]
            )
        } else {
            let predicate: NSPredicate?
            if let profile {
                predicate = NSPredicate(format: "%@ IN %K", profile, #keyPath(Equipment.profiles))
            } else {
                predicate = nil
            }
            _equipment = SectionedFetchRequest(
                sectionIdentifier: \Equipment.type,
                sortDescriptors: [
                    SortDescriptor(\Equipment.type),
                    SortDescriptor(\.brand),
                    SortDescriptor(\.name)
                ],
                predicate: predicate
            )
        }
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
        .navigationTitle(title)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                if profile != nil {
                    Button {
                        showWeightView = true
                    } label: {
                        Image(systemName: "scalemass.fill")
                    }
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    ForEach(Equipment.EquipmentType.allCases) { type in
                        Button(action: {
                            createEquipmentOperation(type: type)
                        }) {
                            Label {
                                Text(type.localizedName)
                            } icon: {
                                type.iconImage
                            }
                        }
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
                if let profile {
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
    }

    private func createEquipmentOperation(type: Equipment.EquipmentType) {
        let operation: Operation<Equipment> = Operation(withParentContext: managedObjectContext) { context in
            Equipment.create(type: type, context: context)
        }
        if let profile {
            operation.object(for: profile).addToEquipment(operation.object)
        }
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
            
            NavigationView {
                ProfileView(profile: nil)
            }
        }
        .environment(\.locale, .init(identifier: "de"))
        .environment(\.managedObjectContext, CoreData.previewContext)
    }
}
