//
//  WingLoadView.swift
//  Paraquip
//
//  Created by Simon Seyer on 18.03.23.
//

import SwiftUI

struct WingLoadRange: Identifiable {
    let range: ClosedRange<Double>
    let text: LocalizedStringKey
    let color: Color

    var id: Int {
        range.hashValue
    }
}

struct WingLoadView: View {
    
    @ObservedObject var profile: Profile
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.locale) var locale: Locale
    @State private var editEquipmentOperation: Operation<Equipment>?
    @State private var weightRangeVisible = true
    @State private var wingClassesVisible = true
    
    @FetchRequest
    private var equipment: FetchedResults<Equipment>

    private var desiredWingLoadRange: ClosedRange<Double> {
        let defaultMinimum = 3.8
        let defaultMaximum = 4.9
        guard let minWingLoad = profile.minimumWingLoad,
              let maxWingLoad = profile.maximumWingLoad else {
            return (defaultMinimum)...(defaultMaximum)
        }
        let lowerBound = min(defaultMinimum, minWingLoad - 0.1)
        let upperBound = max(defaultMaximum, maxWingLoad + 0.1)
        return lowerBound...upperBound
    }
    
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

    private func relativeWidth(of range: ClosedRange<Double>) -> Double {
        relativePosition(of: range.upperBound) - relativePosition(of: range.lowerBound)
    }

    private var wingLoadRanges: [WingLoadRange] {
        [
            WingLoadRange(
                range: (desiredWingLoadRange.lowerBound)...(4.1),
                text: "Very low",
                color: .accentColor.opacity(0.25)
            ),
            WingLoadRange(
                range: (4.1)...(4.3),
                text: "Low",
                color: .accentColor.opacity(0.7)
            ),
            WingLoadRange(
                range: (4.3)...(4.5),
                text: "Middle",
                color: .accentColor.opacity(1.0)
            ),
            WingLoadRange(
                range: (4.5)...(4.7),
                text: "High",
                color: .accentColor.opacity(0.7)
            ),
            WingLoadRange(
                range: (4.7)...(desiredWingLoadRange.upperBound),
                text: "Very high",
                color: .accentColor.opacity(0.25)
            )
        ]
    }

    private let wingClassWingLoad: [(Text, Double)] = [
        (Text("A"), 4.0),
        (Text("\(Image(systemName: "arrow.down"))B"), 4.1),
        (Text("\(Image(systemName: "arrow.up"))B"), 4.3),
        (Text("C"), 4.6)
    ]

    private let height: Double = 40.0
    private let legendRowHeight: Double = 18

    
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
                    VStack(spacing: 0) {
                        Text("Desired wing load")
                            .font(.headline)
                            .padding(.bottom)

                        ZStack(alignment: .top) {
                            GeometryReader { geometry in
                                HStack(alignment: .top, spacing: 0) {
                                    ForEach(wingLoadRanges) { range in
                                        Rectangle()
                                            .foregroundColor(range.color)
                                            .frame(width: relativeWidth(of: range.range) * geometry.size.width,
                                                   height: height)
                                    }
                                }

                                if weightRangeVisible, let wingLoad = profile.minimumWingLoad {
                                    Rectangle()
                                        .overlay(alignment: .trailing) {
                                            VStack {
                                                Spacer()
                                                Image(systemName: "arrow.right")
                                                    .foregroundColor(.black)
                                                    .font(.system(size: 8, weight: .bold))
                                                    .padding(.bottom, 8)
                                                    .padding(.trailing, 6)
                                            }
                                        }
                                        .foregroundColor(Color(UIColor.systemOrange))
                                        .frame(width: geometry.size.width * relativePosition(of: wingLoad),
                                               height: height)
                                        .opacity(0.6)
                                }

                                if weightRangeVisible, let wingLoad = profile.maximumWingLoad {
                                    Rectangle()
                                        .overlay(alignment: .leading) {
                                            VStack {
                                                Spacer()
                                                Image(systemName: "arrow.left")
                                                    .foregroundColor(.black)
                                                    .font(.system(size: 8, weight: .bold))
                                                    .padding(.bottom, 8)
                                                    .padding(.leading, 6)
                                            }
                                        }
                                        .foregroundColor(Color(UIColor.systemOrange))
                                        .frame(width: geometry.size.width - geometry.size.width * relativePosition(of: wingLoad), height: height)
                                        .padding(.leading,  geometry.size.width * relativePosition(of: wingLoad))
                                        .opacity(0.6)
                                }

                                if let wingLoad = profile.wingLoad {
                                    VStack {
                                        Spacer()
                                        Circle()
                                            .foregroundColor(Color(UIColor.systemYellow))
                                            .frame(width: 10, height: 10)
                                            .position(
                                                x: (geometry.size.width - 14) * relativePosition(of: wingLoad) + 7,
                                                y: 20)
                                    }
                                }

                                if let wingLoad = profile.desiredWingLoad {
                                    VStack {
                                        Spacer()
                                        Circle()
                                            .strokeBorder(Color(UIColor.systemYellow), lineWidth: 3)
                                            .frame(width: 16, height: 16)
                                            .position(
                                                x: (geometry.size.width - 20) * relativePosition(of: wingLoad) + 10,
                                                y: 20)
                                    }
                                }
                                if wingClassesVisible {
                                    ForEach(wingClassWingLoad, id: \.1) { wingClass in
                                        WingClassPill(text: wingClass.0)
                                            .position(
                                                x: geometry.size.width * relativePosition(of: wingClass.1),
                                                y: 11)
                                    }
                                }
                            }
                            .frame(height: height)
                            .cornerRadius(6)
                            .padding(.bottom, 4)
                        }

                        GeometryReader { geometry in
                            HStack(alignment: .top, spacing: 0) {
                                ForEach(wingLoadRanges) { range in
                                    Text(range.text)
                                        .font(.caption2)
                                        .frame(width: relativeWidth(of: range.range) * geometry.size.width)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }

                        HStack(spacing: 2) {
                            Slider(value: $profile.desiredWingLoad, in: desiredWingLoadRange)
                                .padding(.trailing, 8)
                            Text(profile.desiredWingLoad, format: .number.precision(.fractionLength(2)))
                                .monospacedDigit()
                            Text("kg/m²")
                        }
                        .tint(Color(UIColor.systemYellow))
                        .padding([.leading, .trailing], 6)
                        .padding([.top, .bottom], 24)

                        VStack(alignment: .leading) {
                            HStack {
                                Circle()
                                    .strokeBorder(Color(UIColor.systemYellow), lineWidth: 2)
                                    .frame(width: 14, height: 14)
                                    .padding( 3)
                                Text("Desired wing load")
                            }
                            .frame(height: legendRowHeight)
                            HStack {
                                Circle()
                                    .foregroundColor(Color(UIColor.systemYellow))
                                    .frame(width: 10, height: 10)
                                    .padding(5)
                                Text("Current wing load")
                            }
                            .frame(height: legendRowHeight)
                            HStack {
                                Rectangle()
                                    .overlay(alignment: .trailing) {
                                        VStack {
                                            Spacer()
                                            Image(systemName: "arrow.right")
                                                .foregroundColor(.black)
                                                .font(.system(size: 5, weight: .bold))
                                                .padding(.bottom, 3)
                                                .padding(.trailing, 1)
                                        }
                                    }
                                    .foregroundColor(Color(UIColor.systemOrange))
                                    .opacity(0.6)
                                    .frame(width: 10, height: 20)
                                    .padding(5)
                                Text("Certified weight range \((profile.minimumWingLoad != nil || profile.maximumWingLoad != nil) ? (weightRangeVisible ? Image(systemName: "eye.fill") : Image(systemName: "eye.slash.fill")) : Image(systemName: "x.circle.fill"))")
                            }
                            .frame(height: legendRowHeight)
                            .opacity(weightRangeVisible && (profile.minimumWingLoad != nil || profile.maximumWingLoad != nil) ? 1 : 0.3)
                            .onTapGesture {
                                withAnimation {
                                    weightRangeVisible.toggle()
                                }
                            }
                            HStack {
                                WingClassPill(text: Text("A"))
                                Text("Common wing load by EN-class \(wingClassesVisible ? Image(systemName: "eye.fill") : Image(systemName: "eye.slash.fill"))")
                            }
                            .frame(height: legendRowHeight)
                            .opacity(wingClassesVisible ? 1 : 0.3)
                            .onTapGesture {
                                withAnimation {
                                    wingClassesVisible.toggle()
                                }
                            }
                            Divider()
                            Text("wing_load_disclaimer")
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(6)
                        .font(.caption)
                        .padding([.leading, .trailing], 6)
                    }
                    .padding([.leading, .trailing], 8)
                    .padding([.top, .bottom])
                    .background(Color(UIColor.systemGroupedBackground))
                    .cornerRadius(6)
                    .padding(8)



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

    static var veryLowWingLoadProfile: Profile {
        let profile = Profile.create(context: CoreData.previewContext, name: "")
        let paraglider = Paraglider.create(context: CoreData.previewContext)
        paraglider.brandName = "Gin"
        paraglider.name = "Bolero 7"
        paraglider.equipmentSize = "XXS"
        paraglider.projectedArea = 18.83
        paraglider.weightRangeMeasurement = (.init(value: 55, unit: .kilograms))...(.init(value: 80, unit: .kilograms))
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
            NavigationStack {
                WingLoadView(profile: veryLowWingLoadProfile)
            }
            .previewDisplayName("Very Low Wing Load")
        }
        .environment(\.managedObjectContext, CoreData.previewContext)
        .environment(\.locale, .init(identifier: "de"))
    }
}
