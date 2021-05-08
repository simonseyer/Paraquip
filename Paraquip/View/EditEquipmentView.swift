//
//  EditEquipmentView.swift
//  Paraquip
//
//  Created by Simon Seyer on 18.04.21.
//

import SwiftUI

struct EditEquipmentView: View {

    enum BrandSelection {
        case known(_: Brand)
        case custom
        case none

        var isSelected: Bool {
            if case .none = self {
                return false
            }
            return true
        }
    }

    @EnvironmentObject var store: ProfileStore

    @State var equipment: Equipment
    @State var sizeIndex: Int = 4
    @State var brandIndex: Int = 0
    @State var customBrandName: String = ""
    @State var checkCycle: Double = 12
    @State var lastCheckDate: Date = Date()

    private var brand: Brand? {
        switch brandOptions[brandIndex] {
        case .none:
            return nil
        case .custom:
            return Brand(name: customBrandName, id: nil)
        case .known(let selectedBrand):
            return selectedBrand
        }
    }

    private let dismiss: () -> Void

    let sizeOptions = ["XXS", "XS", "S", "SM", "M", "L", "XL", "XXL"]
    let brandOptions: [BrandSelection] = {
        return [.none, .custom] + Brand.allBrands.map { .known($0) }
    }()

    var title: String {
        if let brand = brand, !brand.name.isEmpty {
            return "\(brand.name) \(equipment.localizedType)"
        } else {
            return "New \(equipment.localizedType)"
        }
    }

    init(equipment: Equipment, dismiss: @escaping () -> Void ) {
        self.dismiss = dismiss

        self._equipment = State(initialValue: equipment)

        if let brandId = equipment.brand.id {
            let brandIndex = brandOptions.firstIndex { brandSelection in
                if case .known(let brand) = brandSelection {
                    return brand.id == brandId
                }
                return false
            } ?? 0
            _brandIndex = State(initialValue: brandIndex)
        } else if !equipment.brand.name.isEmpty {
            _brandIndex = State(initialValue: 1) // .custom
            _customBrandName = State(initialValue: equipment.brand.name)
        }

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
                Picker(selection: $brandIndex, label: Text("Brand")) {
                    ForEach(0 ..< brandOptions.count) { index in
                        switch self.brandOptions[index] {
                        case .none:
                            Text("None")
                        case .custom:
                            Text("Custom")
                        case .known(let brand):
                            BrandRow(brand: brand)
                        }
                    }
                }
                if case .custom = brandOptions[brandIndex] {
                    HStack {
                        Text("Custom Brand")
                        Spacer()
                        TextField("Brand", text: $customBrandName)
                            .multilineTextAlignment(.trailing)
                    }
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
                if equipment.checkLog.isEmpty {
                    HStack {
                        DatePicker("Last check", selection: $lastCheckDate, displayedComponents: .date)
                    }
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
                    guard let brand = brand else {
                        preconditionFailure("No brand selected")
                    }

                    equipment.brand = brand
                    if equipment.checkLog.isEmpty {
                        equipment.checkLog.append(Check(date: lastCheckDate))
                    }

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
                .disabled(!brandOptions[brandIndex].isSelected)
            }
        }

    }
}

struct AddEquipmentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EditEquipmentView(equipment:Profile.fake().equipment.first!,
                              dismiss: {})
                .environmentObject(ProfileStore(profile: Profile.fake()))
        }

        NavigationView {
            EditEquipmentView(equipment: Paraglider.new(),
                              dismiss: {})
                .environmentObject(ProfileStore(profile: Profile.fake()))
        }

        NavigationView {
            EditEquipmentView(equipment: Paraglider(brand: Brand(name: "Heyho"), name: "Test", size: "M", checkCycle: 6),
                              dismiss: {})
                .environmentObject(ProfileStore(profile: Profile.fake()))
        }

        NavigationView {
            EditEquipmentView(equipment:Profile.fake().equipment.last!,
                              dismiss: {})
                .environmentObject(ProfileStore(profile: Profile.fake()))
        }
    }
}
