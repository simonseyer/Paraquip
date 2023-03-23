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
    
    @FetchRequest
    private var equipment: FetchedResults<Equipment>
    
    init(profile: Profile) {
        self.profile = profile
        _equipment = FetchRequest(
            previewEntity: Equipment.previewEntity,
            sortDescriptors: Equipment.defaultSortDescriptors(),
            predicate: profile.equipmentPredicate
        )
    }

    let wingLoadRanges: [(String, Color)] = [
        ("Very low", .accentColor.opacity(0.25)),
        ("Low", .accentColor.opacity(0.7)),
        ("Middle", .accentColor.opacity(1.0)),
        ("High", .accentColor.opacity(0.7)),
        ("Very high", .accentColor.opacity(0.25))
    ]
    
    var body: some View {
        VStack {
            Text("Wing load")
                .font(.title)
                .padding(.bottom)
            Text("wing_load_explanation")
                // fixes glitch when closing sheet
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 8) {
                HStack {
                    Text("Desired wing load:")
                        .bold()
                    Text(profile.desiredWingLoad, format: .number.precision(.fractionLength(2)))
                        .monospacedDigit()
                }

                Slider(value: $profile.desiredWingLoad, in: (3.8)...(4.9))

                GeometryReader { geometry in
                    HStack(alignment: .top, spacing: 0) {
                        ForEach(wingLoadRanges, id: \.0) { range in
                            VStack {
                                Rectangle()
                                    .foregroundColor(range.1)
                                    .frame(height: 10)
                                Text(LocalizedStringKey(range.0))
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                            }.frame(width: 0.2 * geometry.size.width)
                        }
                    }
                    .font(.caption)
                }

            }.padding([.top])

            Spacer()
            if profile.paraglider == nil {
                Button(action: {
                    let operation: Operation<Equipment> = Operation(withParentContext: managedObjectContext) { context in
                        Equipment.create(type: .paraglider, context: context)
                    }
                    operation.object(for: profile).addToEquipment(operation.object)
                    editEquipmentOperation = operation
                }) {
                    Text("Add paraglider")
                        .frame(maxWidth: .infinity)
                }
            } else if let paraglider = profile.paraglider,
                      paraglider.projectedArea == nil {
                Button(action: {
                    editEquipmentOperation = Operation(editing: paraglider,
                                                       withParentContext: managedObjectContext)
                }) {
                    Text("Enter projected area")
                        .frame(maxWidth: .infinity)
                }
            }
            let _ = equipment // Required to observe equipment for (weight) changes
        }
        .buttonStyle(.bordered)
        .controlSize(.large)
        .padding([.top, .leading, .trailing], 30)
        .sheet(item: $editEquipmentOperation) { operation in
            NavigationView {
                EditEquipmentView(equipment: operation.object,
                                  locale: locale,
                                  focusedField: profile.paraglider != nil ? .projectedArea : nil)
                    .environment(\.managedObjectContext, operation.childContext)
            }
        }
    }
}

struct WingLoadView_Previews: PreviewProvider {
    
    static var noWingLoadProfile: Profile {
        let profile = Profile.create(context: CoreData.previewContext, name: "")
        let paraglider = Paraglider.create(context: CoreData.previewContext)
        paraglider.brandName = "ABC"
        paraglider.name = "Def"
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
