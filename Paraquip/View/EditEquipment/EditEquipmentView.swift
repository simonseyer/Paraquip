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
        if !viewModel.brand.name.isEmpty {
            return Text("\(viewModel.equipment.brand.name) \(NSLocalizedString(viewModel.equipment.localizedType, comment: ""))")
        } else {
            return Text("\(NSLocalizedString("New", comment: "")) \(NSLocalizedString(viewModel.equipment.localizedType, comment: ""))")
        }
    }

    var body: some View {
        Form {
            Section(header: Text("")) {
                Picker(selection: $viewModel.brand, label: Text("Brand")) {
                    ForEach(Brand.allCases) { brand in
                        BrandRow(brand: brand)
                            .tag(brand)
                    }
                }
                if case .custom = viewModel.brand {
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
                    Picker(selection: $viewModel.paragliderSize, label: Text("Size")) {
                        ForEach(Paraglider.Size.allCases) { size in
                            Text(size.rawValue)
                                .tag(size)
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
                                    .foregroundColor(Color.green)
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
                                    .foregroundColor(Color.green)
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
                .disabled(viewModel.brand == .none)
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
                EditEquipmentView(viewModel: EditEquipmentViewModel(store: store, equipment: Paraglider(), isNew: true), dismiss: {})
            }

            NavigationView {
                EditEquipmentView(viewModel: EditEquipmentViewModel(store: store, equipment: Paraglider(brand: .custom(name: "Heyho"), name: "Test", size: .medium, checkCycle: 6), isNew: false), dismiss: {})
            }

            NavigationView {
                EditEquipmentView(viewModel: EditEquipmentViewModel(store: store, equipment: Profile.fake().equipment.last!, isNew: false), dismiss: {})
            }
        }.environment(\.locale, .init(identifier: "de"))
    }
}
