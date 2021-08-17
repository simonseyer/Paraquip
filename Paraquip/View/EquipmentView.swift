//
//  EquipmentView.swift
//  Paraquip
//
//  Created by Simon Seyer on 18.04.21.
//

import SwiftUI

struct EquipmentView: View {

    @EnvironmentObject var store: ProfileViewModel
    let equipmentId: UUID

    private var equipment: Equipment {
        store.equipment(with: equipmentId) ?? PlaceholderEquipment()
    }

    @State private var showingAddEquipment = false
    @State private var showingLogCheck = false
    @State private var editMode: EditMode = .inactive

    @Environment(\.locale) var locale

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text("by \(equipment.brand.name)")
                        .font(.headline)
                    HStack {
                        PillLabel(LocalizedStringKey(equipment.localizedType))
                        if let paraglider = equipment as? Paraglider {
                            PillLabel("Size \(paraglider.size)")
                        }
                    }
                    .padding([.top, .bottom], 10)
                }
                Spacer()
                if let icon = equipment.icon {
                    icon
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                }
            }
            .padding([.leading, .trailing])

            List {
                if equipment.timeline.isEmpty {
                    Text("No check logged")
                        .foregroundColor(Color(UIColor.systemGray))
                } else {
                    ForEach(equipment.timeline) { entry in
                        TimelineViewCell(timelineEntry: entry) {
                            showingLogCheck = true
                        }
                        .deleteDisabled(!entry.isCheck)
                    }
                    .onDelete(perform: { indexSet in
                        let offsets = equipment.timeline.checkIndexSet(from: indexSet)
                        store.removeChecks(for: equipment, atOffsets: offsets)
                        if equipment.checkLog.isEmpty {
                            withAnimation {
                                editMode = .inactive
                            }
                        }
                    })
                }
            }
            .listStyle(InsetGroupedListStyle())
            .environment(\.editMode, $editMode)
            .toolbar(content: {
                Button("Edit") {
                    showingAddEquipment = true
                }
            })
            .navigationTitle(equipment.name)
            .sheet(isPresented: $showingAddEquipment) {
                NavigationView {
                    EditEquipmentView(equipment: equipment) {
                        showingAddEquipment = false
                    }
                }
            }
            .sheet(isPresented: $showingLogCheck) {
                LogCheckView() { date in
                    if let checkDate = date {
                        store.logCheck(for: equipment, date: checkDate)
                    }
                    showingLogCheck = false
                }
            }
        }
    }
}

struct PlaceholderEquipment: Equipment {
    var id: UUID = .init()
    var brand: Brand = .init(name: "")
    var name: String = ""
    var checkCycle: Int = 0
    var checkLog: [Check] = []
    var purchaseDate: Date? = nil
}

extension Equipment {
    var localizedType: String {
        switch self {
        case is Paraglider:
            return "Paraglider"
        case is Reserve:
            return "Reserve"
        case is Harness:
            return "Harness"
        case is PlaceholderEquipment:
            return ""
        default:
            preconditionFailure("Unknown equipment type")
        }
    }

    var timeline: [TimelineEntry] {
        var timeline: [TimelineEntry] = []

        timeline.append(.nextCheck(date: nextCheck,
                                   urgency: checkUrgency))

        timeline.append(contentsOf: checkLog.map {
            .check(check: $0)
        })

        if let purchaseDate = purchaseDate {
            timeline.append(.purchase(date: purchaseDate))
        }

        return timeline
    }
}

extension Array where Element == TimelineEntry {
    /// Returns an index set mapped back to the check log
    func checkIndexSet(from indexSet: IndexSet) -> IndexSet {
        guard let firstIndex = indexSet.first else {
            return indexSet
        }
        var newIndexSet = indexSet
        newIndexSet.shift(startingAt: firstIndex, by: -1)
        return newIndexSet
    }
}

struct EquipmentView_Previews: PreviewProvider {

    private static let profile = Profile.fake()

    static var previews: some View {
        Group {
            NavigationView {
                EquipmentView(equipmentId: profile.equipment.first!.id)
                    .environmentObject(ProfileViewModel(store: FakeProfileStore(profile: profile)))
            }

            NavigationView {
                EquipmentView(equipmentId: profile.equipment.last!.id)
                    .environmentObject(ProfileViewModel(store: FakeProfileStore(profile: profile)))
            }
        }
        .environment(\.locale, .init(identifier: "de"))
    }
}

struct PillLabel: View {

    let content: LocalizedStringKey

    init(_ content: LocalizedStringKey) {
        self.content = content
    }

    var body: some View {
        Text(content)
            .font(.caption)
            .padding(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(6)
    }
}
