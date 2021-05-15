//
//  EquipmentView.swift
//  Paraquip
//
//  Created by Simon Seyer on 18.04.21.
//

import SwiftUI

struct EquipmentView: View {

    @EnvironmentObject var store: ProfileStore
    let equipmentId: UUID

    private var equipment: Equipment {
        store.equipment(with: equipmentId) ?? PlaceholderEquipment()
    }

    @State private var showingAddEquipment = false
    @State private var editMode: EditMode = .inactive
    @State private var newCheckDate = Date()

    @Environment(\.locale) var locale

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()

    var body: some View {
        List {
            Section(header: Text("Equipment")) {
                HStack {
                    Text("Type")
                    Spacer()
                    Text(LocalizedStringKey( equipment.localizedType))
                }
                HStack {
                    Text("Brand")
                    Spacer()
                    BrandRow(brand: equipment.brand)
                }
                HStack {
                    Text("Name")
                    Spacer()
                    Text(equipment.name)
                }
                if let paraglider = equipment as? Paraglider {
                    HStack {
                        Text("Size")
                        Spacer()
                        Text(paraglider.size)
                    }
                }
                if let purchaseDate = equipment.purchaseDate {
                    HStack {
                        Text("Purchase Date")
                        Spacer()
                        Text(formatted(date: purchaseDate))
                    }
                }
            }
            Section(header: Text("Check")) {
                HStack {
                    Text("Check cycle")
                    Spacer()
                    Text("\(equipment.checkCycle) months")
                }

                HStack {
                    Text("Next check")
                    Spacer()
                    Text(equipment.formattedCheckInterval(locale: locale))
                        .foregroundColor(equipment.checkIntervalColor)
                }

                HStack {
                    DatePicker("Log check", selection: $newCheckDate, displayedComponents: .date)
                    Button(action: {
                        store.logCheck(for: equipment, date: newCheckDate)
                        newCheckDate = Date()
                    }, label: {
                        Image(systemName: "plus.circle.fill")
                    })
                    .disabled(editMode == .active)
                }

            }
            Section(header: HStack {
                Text("Check Log")
                Spacer()
                Button(editMode == .inactive ? "Edit" : "Done") {
                    withAnimation {
                        editMode.toggle()
                    }
                }
                .animation(.none)
                .disabled(equipment.checkLog.isEmpty)
            }) {
                if equipment.checkLog.isEmpty {
                    Text("No check logged")
                        .foregroundColor(Color(UIColor.systemGray))
                } else {
                    ForEach(equipment.checkLog) { check in
                        Text(dateFormatter.string(from: check.date))
                    }
                    .onDelete(perform: { indexSet in
                        store.removeChecks(for: equipment, atOffsets: indexSet)
                        if equipment.checkLog.isEmpty {
                            withAnimation {
                                editMode = .inactive
                            }
                        }
                    })
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .environment(\.editMode, $editMode)
        .toolbar(content: {
            Button("Edit") {
                showingAddEquipment = true
            }
        })
        .navigationTitle("\(equipment.brand.name) \(equipment.name)")
        .sheet(isPresented: $showingAddEquipment) {
            NavigationView {
                EditEquipmentView(equipment: equipment) {
                    showingAddEquipment = false
                }
            }
        }
    }

    private func formatted(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = locale
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: date)
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
}

struct EquipmentView_Previews: PreviewProvider {

    private static let profile = Profile.fake()

    static var previews: some View {
        Group {
            NavigationView {
                EquipmentView(equipmentId: profile.equipment.first!.id)
                    .environmentObject(ProfileStore(profile: profile))
            }

            NavigationView {
                EquipmentView(equipmentId: profile.equipment.last!.id)
                    .environmentObject(ProfileStore(profile: profile))
            }
        }
        .environment(\.locale, .init(identifier: "de"))
    }
}
