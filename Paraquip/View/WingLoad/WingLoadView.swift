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

    private let desiredWingLoadRange = (3.8)...(4.9)
    
    init(profile: Profile) {
        self.profile = profile
        _equipment = FetchRequest(
            previewEntity: Equipment.previewEntity,
            sortDescriptors: Equipment.defaultSortDescriptors(),
            predicate: profile.equipmentPredicate
        )
    }

    private func relativePosition(of wingLoad: Double) -> Double {
        (wingLoad - desiredWingLoadRange.lowerBound) / (desiredWingLoadRange.upperBound - desiredWingLoadRange.lowerBound)
    }

    private let wingLoadRanges: [(String, Color)] = [
        ("Very low", .accentColor.opacity(0.25)),
        ("Low", .accentColor.opacity(0.7)),
        ("Middle", .accentColor.opacity(1.0)),
        ("High", .accentColor.opacity(0.7)),
        ("Very high", .accentColor.opacity(0.25))
    ]

    private let wingClassWingLoad: [(Text, Double)] = [
        (Text("A"), 4.0),
        (Text("\(Image(systemName: "arrow.down"))B"), 4.1),
        (Text("\(Image(systemName: "arrow.up"))B"), 4.3),
        (Text("C"), 4.6)
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Text("Wing load")
                        .font(.title)
                        .padding(.bottom, 8)

                    Text("wing_load_calculation")

                    VStack(spacing: 4) {
                        Text("Full takeoff weight (kg)")
                            .padding([.leading, .trailing], 4)
                        Divider()
                            .frame(height: 1)
                            .overlay(.primary)
                        Text("Projected area of the wing (m²)")
                            .padding([.leading, .trailing], 4)
                    }
                    .fixedSize()
                    .monospaced()
                    .font(.caption)
                    .padding([.top, .bottom], 8)

                    Text("wing_load_explanation")
                }
                .padding([.top, .leading, .trailing])

                if profile.paraglider?.projectedArea != nil {
                    VStack(spacing: 8) {
                        HStack {
                            Text("Desired wing load:")
                                .bold()
                            Text(profile.desiredWingLoad, format: .number.precision(.fractionLength(2)))
                                .monospacedDigit()
                        }

                        Slider(value: $profile.desiredWingLoad, in: desiredWingLoadRange)

                        ZStack(alignment: .top) {
                            GeometryReader { geometry in
                                HStack(alignment: .top, spacing: 0) {
                                    ForEach(wingLoadRanges, id: \.0) { range in
                                        VStack {
                                            Rectangle()
                                                .foregroundColor(range.1)
                                                .frame(height: 24)
                                            Text(LocalizedStringKey(range.0))
                                                .lineLimit(2)
                                                .multilineTextAlignment(.center)
                                        }.frame(width: 0.2 * geometry.size.width)
                                    }
                                }
                                .font(.caption)

                                ForEach(wingClassWingLoad, id: \.1) { wingClass in
                                    WingClassPill(text: wingClass.0)
                                        .position(
                                            x: geometry.size.width * relativePosition(of: wingClass.1),
                                            y: 12)
                                }
                            }.frame(height: 64)
                        }

                        Text("wing_load_disclaimer")
                            .font(.caption2)
                    }
                    .padding([.leading, .trailing], 8)
                    .padding([.top, .bottom])
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(6)
                    .padding([.leading, .trailing], 8)
                    .padding([.top, .bottom], 8)

                    HStack {
                        Spacer()
                        HStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.title)
                            Text("weight_range_warning")
                                .font(.subheadline)
                        }
                        .padding(12)
                        .background(Color(UIColor.systemYellow).opacity(0.2))
                        .cornerRadius(6)
                        Spacer()

                    }.padding(.bottom, 8)

                    VStack(alignment: .leading) {
                        Text("Guidance")
                            .font(.title2)
                            .padding(.bottom, 4)
                        Text("Lower wing load \(Image(systemName: "arrow.down"))")
                            .font(.title3)
                            .padding(.bottom, 2)
                        Text("lower_wing_load_list")

                        Text("Higher wing load \(Image(systemName: "arrow.up"))")
                            .font(.title3)
                            .padding([.bottom, .top], 2)
                        Text("higher_wing_load_list")

                        Text("Further reading")
                            .font(.title2)
                            .padding([.bottom, .top], 4)
                        Text("further_reading_text")

                    }.padding([.leading, .trailing])
                        .font(.body.leading(.loose))
                }

                VStack {
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
                        }.padding()
                    } else if let paraglider = profile.paraglider,
                              paraglider.projectedArea == nil {
                        Button(action: {
                            editEquipmentOperation = Operation(editing: paraglider,
                                                               withParentContext: managedObjectContext)
                        }) {
                            Text("Enter projected area")
                                .frame(maxWidth: .infinity)
                        }.padding()
                    }
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                let _ = equipment // Required to observe equipment for (weight) changes
            }
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
