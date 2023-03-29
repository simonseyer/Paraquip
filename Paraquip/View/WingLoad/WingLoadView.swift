//
//  WingLoadView.swift
//  Paraquip
//
//  Created by Simon Seyer on 18.03.23.
//

import SwiftUI

struct WingLoadView: View {
    
    @ObservedObject var profile: Profile
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.locale) var locale: Locale
    @State private var editEquipmentOperation: Operation<Equipment>?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Wing load")
                    .font(.title)

                Text("wing_load_calculation")

                WingLoadCalculationGraphic()

                Text("wing_load_explanation")

                if let wingLoad = profile.wingLoad {
                    DesiredWingLoadView(
                        profile: profile,
                        wingLoad: wingLoad
                    )
                    .padding([.leading, .trailing], -8)
                } else if let paraglider = profile.paraglider {
                    ProminentButton(text: "Enter projected area") {
                        editEquipment(equipment: paraglider)
                    }
                } else {
                    ProminentButton(text: "Add paraglider") {
                        createEquipment(type: .paraglider)
                    }
                }

                WingLoadGuidanceView()
            }
            .padding()
        }
        .sheet(item: $editEquipmentOperation) { operation in
            NavigationView {
                EditEquipmentView(equipment: operation.object,
                                  locale: locale,
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

fileprivate struct ProminentButton: View {

    let text: LocalizedStringKey
    let action: () -> Void

    @ViewBuilder
    var body: some View {
        Button(action: action) {
            Text(text)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
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
