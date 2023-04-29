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
                    Text("Wing load")
                        .font(.title)

                    Text("wing_load_calculation")

                    WingLoadCalculationGraphic()

                    Text("wing_load_explanation")
                }
                .textSelection(.enabled)

                DesiredWingLoadView(profile: profile)
                    .padding([.leading, .trailing], -8)

                WingLoadGuidanceView()
            }
            .padding()

            let _ = equipment // Required to observe equipment for (weight) changes
        }
        .safeAreaInset(edge: .bottom) {
            if profile.wingLoadValue == nil {
                Group {
                    if let paraglider = profile.paraglider {
                        Button {
                            editEquipment(equipment: paraglider)
                        } label: {
                            Text("Enter projected area")
                                .frame(maxWidth: .infinity)
                        }
                    } else {
                        Button {
                            createEquipment(type: .paraglider)
                        } label: {
                            Text("Add paraglider")
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
        }
        .sheet(item: $editEquipmentOperation) { operation in
            NavigationView {
                EditEquipmentView(equipment: operation.object,
                                  focusedField: profile.paraglider != nil ? .projectedArea : nil)
                .environment(\.managedObjectContext, operation.childContext)
            }
        }
    }

    func editEquipment(equipment: Equipment) {
        editEquipmentOperation = Operation(editing: equipment,
                                           withParentContext: managedObjectContext)
    }

    func createEquipment(type: Equipment.EquipmentType) {
        let operation: Operation<Equipment> = Operation(withParentContext: managedObjectContext) { context in
            Equipment.create(type: type, context: context)
        }
        operation.object(for: profile).addToEquipment(operation.object)
        editEquipmentOperation = operation
    }
}

struct WingLoadView_Previews: PreviewProvider {
    
    static var noWingLoadProfile: Profile {
        let profile = Profile.create(context: CoreData.previewContext, name: "")
        let paraglider = Paraglider.create(context: CoreData.previewContext)
        paraglider.brandName = "Gin"
        paraglider.name = "Explorer 2"
        profile.addToEquipment(paraglider)
        return profile
    }
    
    static var previews: some View {
        Group {
            NavigationStack {
                WingLoadView(profile: CoreData.fakeProfile)
            }
            NavigationStack {
                WingLoadView(profile: Profile.create(context: CoreData.previewContext, name: "Empty"))
            }
            .previewDisplayName("No Paraglider")
            NavigationStack {
                WingLoadView(profile: noWingLoadProfile)
            }
            .previewDisplayName("No Wing Load")
        }
        .environment(\.managedObjectContext, CoreData.previewContext)
        .environment(\.locale, .init(identifier: "de"))
    }
}
