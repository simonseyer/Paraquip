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

    @EnvironmentObject var store: ProfileViewModel

    @State var equipment: Equipment
    @State var sizeIndex: Int = 4
    @State var brandIndex: Int = 0
    @State var customBrandName: String = ""
    @State var checkCycle: Double = 12
    @State var lastCheckDate: Date?
    @State var manualURL: URL?
    @State var showingLogCheck = false
    @State var showingManualPicker = false

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

    private let isNew: Bool
    private let dismiss: () -> Void

    let sizeOptions = ["XXS", "XS", "S", "SM", "M", "L", "XL", "XXL"]
    let brandOptions: [BrandSelection] = {
        return [.none, .custom] + Brand.allBrands.map { .known($0) }
    }()

    var title: Text {
        if let brand = brand, !brand.name.isEmpty {
            return Text("\(brand.name) \(NSLocalizedString(equipment.localizedType, comment: ""))")
        } else {
            return Text("\(NSLocalizedString("New", comment: "")) \(NSLocalizedString(equipment.localizedType, comment: ""))")
        }
    }

    init(equipment: Equipment, isNew: Bool, dismiss: @escaping () -> Void ) {
        self.isNew = isNew
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
            Section(header: Text("")) {
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
                        Text("Custom brand")
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
                if equipment is Paraglider {
                    Picker(selection: $sizeIndex, label: Text("Size")) {
                        ForEach(0 ..< sizeOptions.count) {
                            Text(self.sizeOptions[$0])
                        }
                    }
                }
                FormDatePicker(label: "Purchase Date",
                               date: $equipment.purchaseDate)
            }
            Section(header: Text("Check cycle")) {
                HStack {
                    Slider(value: $checkCycle, in: 3...36, step: 1) {
                        EmptyView()
                    }
                    Text("\(Int(checkCycle)) months")
                }
            }
            if isNew {
                Section(header: Text("Next steps")) {
                    Button(action: { showingLogCheck.toggle() }) {
                        HStack {
                            FormIcon(icon: Image(systemName: "checkmark.circle.fill"))
                                .padding(.trailing, 8)
                            Text("Log last check")
                            Spacer()
                            if lastCheckDate != nil {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color.accentColor)
                            }
                        }
                        .foregroundColor(.primary)
                        .padding([.top, .bottom], 6)
                    }


                    Button(action: { showingManualPicker = true }) {
                        HStack {
                            FormIcon(icon: Image(systemName: "book.fill"))
                                .padding(.trailing, 8)
                            Text("Attach Manual")
                            Spacer()
                            if manualURL != nil {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color.accentColor)
                            }
                        }
                        .foregroundColor(.primary)
                        .padding([.top, .bottom], 6)
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
                    equipment.checkCycle = Int(checkCycle)

                    if var paraglider = equipment as? Paraglider {
                        paraglider.size = sizeOptions[sizeIndex]
                        store.store(
                            equipment: paraglider,
                            lastCheckDate: lastCheckDate,
                            manualURL: manualURL
                        )
                    } else {
                        store.store(
                            equipment: equipment,
                            lastCheckDate: lastCheckDate,
                            manualURL: manualURL
                        )
                    }

                    dismiss()
                }
                .disabled(!brandOptions[brandIndex].isSelected)
            }
        }
        .sheet(isPresented: $showingLogCheck) {
            LogCheckView() { date in
                lastCheckDate = date
                showingLogCheck = false
            }
        }
        .sheet(isPresented: $showingManualPicker) {
            DocumentPicker() { url in
                manualURL = url
            }
        }
    }
}

struct AddEquipmentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                EditEquipmentView(equipment:Profile.fake().equipment.first!,
                                  isNew: false,
                                  dismiss: {})
                    .environmentObject(ProfileViewModel.fake())
            }

            NavigationView {
                EditEquipmentView(equipment: Paraglider.new(),
                                  isNew: true,
                                  dismiss: {})
                    .environmentObject(ProfileViewModel.fake())
            }

            NavigationView {
                EditEquipmentView(equipment: Paraglider(brand: Brand(name: "Heyho"), name: "Test", size: "M", checkCycle: 6),
                                  isNew: false,
                                  dismiss: {})
                    .environmentObject(ProfileViewModel.fake())
            }

            NavigationView {
                EditEquipmentView(equipment:Profile.fake().equipment.last!,
                                  isNew: false,
                                  dismiss: {})
                    .environmentObject(ProfileViewModel.fake())
            }
        }.environment(\.locale, .init(identifier: "de"))
    }
}
