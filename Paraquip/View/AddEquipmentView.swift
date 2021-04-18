//
//  AddEquipmentView.swift
//  Paraquip
//
//  Created by Simon Seyer on 18.04.21.
//

import SwiftUI

struct AddEquipmentView: View {

    @EnvironmentObject var store: ProfileStore

    @State var equipment: Paraglider
    @Binding var isPresented: Bool

    @State var sizeIndex: Int = 4
    @State var checkCycle: Double = 12

    let sizeOptions = ["XXS", "XS", "S", "SM", "M", "L", "XL", "XXL"]

    var title: String {
        if !equipment.brand.isEmpty && !equipment.name.isEmpty {
            return "\(equipment.brand) \(equipment.name)"
        } else {
            return "New Equipment"
        }
    }

    init(equipment: Paraglider? = nil, isPresented: Binding<Bool>) {
        self._isPresented = isPresented
        if let equipment = equipment {
            self._equipment = State(initialValue: equipment)
            self._sizeIndex = State(initialValue: sizeOptions.firstIndex(where: { (size) -> Bool in
                size == equipment.size
            }) ?? 4)
            self._checkCycle = State(initialValue: Double(equipment.checkCycle))
        } else {
            self._equipment = State(initialValue: Paraglider(brand: "",
                                                             name: "",
                                                             size: "",
                                                             checkCycle: 180))
        }
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
            Section(header: Text("Attributes")) {
                Picker(selection: $sizeIndex, label: Text("Size")) {
                    ForEach(0 ..< sizeOptions.count) {
                        Text(self.sizeOptions[$0])
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
                    isPresented = false
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    equipment.checkCycle = Int(checkCycle)
                    equipment.size = sizeOptions[sizeIndex]

                    store.store(paraglider: equipment)

                    isPresented = false
                }
            }
        }

    }
}

struct AddEquipmentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AddEquipmentView(equipment:Profile.fake().paragliders.first!,
                             isPresented: .constant(true))
                .environmentObject(ProfileStore(profile: Profile.fake()))
        }
    }
}
