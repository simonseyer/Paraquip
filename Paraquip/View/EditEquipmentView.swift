//
//  EditEquipmentView.swift
//  Paraquip
//
//  Created by Simon Seyer on 18.04.21.
//

import SwiftUI

struct EditEquipmentView: View {

    @EnvironmentObject var store: ProfileStore

    @State var equipment: Equipment
    private let dismiss: () -> Void

    @State var sizeIndex: Int = 4
    @State var checkCycle: Double = 12

    let sizeOptions = ["XXS", "XS", "S", "SM", "M", "L", "XL", "XXL"]

    var title: String {
        if !equipment.brand.isEmpty && !equipment.name.isEmpty {
            return "\(equipment.brand) \(equipment.name) \(equipment.localizedType)"
        } else {
            return "New \(equipment.localizedType)"
        }
    }

    init(equipment: Equipment, dismiss: @escaping () -> Void ) {
        self.dismiss = dismiss

        self._equipment = State(initialValue: equipment)
        if let paraglider = equipment as? Paraglider {
            self._sizeIndex = State(initialValue: sizeOptions.firstIndex(where: { (size) -> Bool in
                size == paraglider.size
            }) ?? 4)
        }
        self._checkCycle = State(initialValue: Double(equipment.checkCycle))
    }

    var body: some View {
        Form {
            Section(header: Text("Equipment")) {
                HStack {
                    Text("Brand")
                    Spacer()
                    TextField("Brand", text: $equipment.brand)
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("Name")
                    Spacer()
                    TextField("Name", text: $equipment.name)
                        .multilineTextAlignment(.trailing)
                }
            }
            if equipment is Paraglider {
                Section(header: Text("Attributes")) {
                    Picker(selection: $sizeIndex, label: Text("Size")) {
                        ForEach(0 ..< sizeOptions.count) {
                            Text(self.sizeOptions[$0])
                        }
                    }
                }
            }
            Section(header: Text("Check Cycle")) {
                HStack {
                    Slider(value: $checkCycle, in: 3...36, step: 1) {
                        EmptyView()
                    }
                    Text("\(Int(checkCycle)) months")
                }
            }
        }
        
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    if var paraglider = equipment as? Paraglider {
                        paraglider.checkCycle = Int(checkCycle)
                        paraglider.size = sizeOptions[sizeIndex]
                        store.store(equipment: paraglider)
                    } else if var reserve = equipment as? Reserve {
                        reserve.checkCycle = Int(checkCycle)
                        store.store(equipment: reserve)
                    }

                    dismiss()
                }
            }
        }

    }
}

struct AddEquipmentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EditEquipmentView(equipment:Profile.fake().paragliders.first!,
                             dismiss: {})
                .environmentObject(ProfileStore(profile: Profile.fake()))
        }

        NavigationView {
            EditEquipmentView(equipment: Paraglider.new(),
                              dismiss: {})
                .environmentObject(ProfileStore(profile: Profile.fake()))
        }

        NavigationView {
            EditEquipmentView(equipment:Profile.fake().reserves.first!,
                              dismiss: {})
                .environmentObject(ProfileStore(profile: Profile.fake()))
        }
    }
}
