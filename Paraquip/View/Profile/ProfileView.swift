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
    @State private var editEquipmentOperation: Operation<Equipment>?
    @State private var editProfileOperation: Operation<Profile>?
    @State private var deleteEquipment: Equipment?
    @State private var isDeletingEquipment = false
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
        let predicate: NSPredicate?
        if let profile {
            predicate = NSPredicate(format: "%@ IN %K", profile, #keyPath(Equipment.profiles))
        } else {
            predicate = nil
        }
        if ProcessInfo.isPreview {
            _equipment = SectionedFetchRequest(
                entity: NSEntityDescription.entity(forEntityName: "Equipment", in: CoreData.previewContext)!,
                sectionIdentifier: \Equipment.type,
                sortDescriptors: [
                    NSSortDescriptor(key: "type", ascending: true),
                    NSSortDescriptor(key: "brand", ascending: true),
                    NSSortDescriptor(key: "name", ascending: true)
                ],
                predicate: predicate
            )
        } else {
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
                            .swipeActions {
                                Button {
                                    editEquipmentOperation = Operation(editing: equipment,
                                                                       withParentContext: managedObjectContext)
                                } label: {
                                    Label("Edit", systemImage: "slider.vertical.3")
                                }
                                .tint(.blue)
                                
                                Button {
                                    deleteEquipment = equipment
                                    isDeletingEquipment = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                .tint(.red)
                            }
                            .labelStyle(.titleOnly)
                        }
                    } header: {
                        ProfileSectionHeader(equipmentType: section.id)
                    }
                }
                .defaultBackground()
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
                    if let profile {
                        Divider()
                        Button(action: {
                            editProfileOperation = Operation(editing: profile,
                                                             withParentContext: managedObjectContext)
                        }) {
                            Label("Edit", systemImage: "slider.vertical.3")
                        }
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(item: $editEquipmentOperation) { operation in
            NavigationView {
                EditEquipmentView(equipment: operation.object, locale: locale)
                    .environment(\.managedObjectContext, operation.childContext)
                    .onDisappear {
                        try? managedObjectContext.save()
                    }
            }
        }
        .sheet(item: $editProfileOperation) { operation in
            NavigationView {
                EditProfileView(profile: operation.object)
                    .environment(\.managedObjectContext, operation.childContext)
                    .onDisappear {
                        try? managedObjectContext.save()
                    }
            }
        }
        .confirmationDialog(Text("Delete equipment"), isPresented: $isDeletingEquipment, presenting: deleteEquipment) { equipment in
            Button("Delete", role: .destructive) {
                withAnimation {
                    managedObjectContext.delete(equipment)
                    try! managedObjectContext.save()
                }
            }
            Button("Remove from set") {
                withAnimation {
                    profile?.removeFromEquipment(equipment)
                    try! managedObjectContext.save()
                }
            }
            Button("Cancel", role: .cancel) {}
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
        editEquipmentOperation = operation
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
            .previewDisplayName("Empty Profile")
            
            NavigationView {
                ProfileView(profile: nil)
            }
            .previewDisplayName("All Equipment")
        }
        .environment(\.locale, .init(identifier: "de"))
        .environment(\.managedObjectContext, CoreData.previewContext)
    }
}
