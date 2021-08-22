//
//  EditEquipmentView.swift
//  Paraquip
//
//  Created by Simon Seyer on 18.04.21.
//

import SwiftUI

struct EditEquipmentView: View {

    @ObservedObject var viewModel: EditEquipmentViewModel
    let dismiss: () -> Void

    @State private var showingLogCheck = false
    @State private var showingManualPicker = false

    private var title: Text {
        if let brand = viewModel.brand, !brand.name.isEmpty {
            return Text("\(brand.name) \(NSLocalizedString(viewModel.equipment.localizedType, comment: ""))")
        } else {
            return Text("\(NSLocalizedString("New", comment: "")) \(NSLocalizedString(viewModel.equipment.localizedType, comment: ""))")
        }
    }

    var body: some View {
        Form {
            Section(header: Text("")) {
                Picker(selection: $viewModel.brandIndex, label: Text("Brand")) {
                    ForEach(0 ..< viewModel.brandOptions.count) { index in
                        switch viewModel.brandOptions[index] {
                        case .none:
                            Text("None")
                        case .custom:
                            Text("Custom")
                        case .known(let brand):
                            BrandRow(brand: brand)
                        }
                    }
                }
                if case .custom = viewModel.brandSelection {
                    HStack {
                        Text("Custom brand")
                        Spacer()
                        TextField("Brand", text: $viewModel.customBrandName)
                            .multilineTextAlignment(.trailing)
                    }
                }
                HStack {
                    Text("Name")
                    Spacer()
                    TextField("Name", text: $viewModel.equipment.name)
                        .multilineTextAlignment(.trailing)
                }
                if viewModel.equipment is Paraglider {
                    Picker(selection: $viewModel.sizeIndex, label: Text("Size")) {
                        ForEach(0 ..< viewModel.sizeOptions.count) {
                            Text(viewModel.sizeOptions[$0])
                        }
                    }
                }
                FormDatePicker(label: "Purchase Date",
                               date: $viewModel.equipment.purchaseDate)
            }
            Section(header: Text("Check cycle")) {
                CheckCycleRow(checkCycle: $viewModel.checkCycle)
            }
            if viewModel.isNew {
                Section(header: Text("Next steps")) {
                    Button(action: { showingLogCheck.toggle() }) {
                        HStack {
                            FormIcon(icon: Image(systemName: "checkmark.circle.fill"))
                                .padding(.trailing, 8)
                            Text("Log last check")
                            Spacer()
                            if viewModel.lastCheckDate != nil {
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
                            if viewModel.manualURL != nil {
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
                    viewModel.save()
                    dismiss()
                }
                .disabled(!viewModel.brandSelection.isSelected)
            }
        }
        .sheet(isPresented: $showingLogCheck) {
            LogCheckView() { date in
                viewModel.lastCheckDate = date
                showingLogCheck = false
            }
        }
        .sheet(isPresented: $showingManualPicker) {
            DocumentPicker() { url in
                viewModel.manualURL = url
            }
        }
    }
}

struct AddEquipmentView_Previews: PreviewProvider {

    static let store = FakeProfileStore(profile: .fake())

    static var previews: some View {
        Group {
            NavigationView {
                EditEquipmentView(viewModel: EditEquipmentViewModel(store: store, equipment: Profile.fake().equipment.first!, isNew: false), dismiss: {})
            }

            NavigationView {
                EditEquipmentView(viewModel: EditEquipmentViewModel(store: store, equipment: Paraglider.new(), isNew: true), dismiss: {})
            }

            NavigationView {
                EditEquipmentView(viewModel: EditEquipmentViewModel(store: store, equipment: Paraglider(brand: Brand(name: "Heyho"), name: "Test", size: "M", checkCycle: 6), isNew: false), dismiss: {})
            }

            NavigationView {
                EditEquipmentView(viewModel: EditEquipmentViewModel(store: store, equipment: Profile.fake().equipment.last!, isNew: false), dismiss: {})
            }
        }.environment(\.locale, .init(identifier: "de"))
    }
}
