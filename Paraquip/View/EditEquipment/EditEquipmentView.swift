//
//  EditEquipmentView.swift
//  Paraquip
//
//  Created by Simon Seyer on 18.04.21.
//

import SwiftUI
import CoreData

struct EditEquipmentView: View {

    @ObservedObject var equipment: Equipment

    @Environment(\.managedObjectContext) private var managedObjectContext
    @Environment(\.dismiss) private var dismiss

    @State private var showingLogCheck = false
    @State private var showingManualPicker = false
    @State private var lastCheckDate: Date?
    @State private var manualURL: URL?

    private var title: Text {
        if !equipment.brandName.isEmpty {
            return Text("\(equipment.brandName) \(NSLocalizedString(equipment.localizedType, comment: ""))")
        } else {
            return Text("\(NSLocalizedString("New", comment: "")) \(NSLocalizedString(equipment.localizedType, comment: ""))")
        }
    }

    var body: some View {
        Form {
            Section(header: Text("")) {
                Picker(selection: $equipment.equipmentBrand, label: Text("Brand")) {
                    ForEach(Brand.allCases) { brand in
                        BrandRow(brand: brand)
                            .tag(brand)
                    }
                }
                if case .custom = equipment.equipmentBrand {
                    HStack {
                        Text("Custom brand")
                        Spacer()
                        TextField("Brand", text: $equipment.brandName)
                            .multilineTextAlignment(.trailing)
                    }
                }
                HStack {
                    Text("Name")
                    Spacer()
                    TextField("Name", text: $equipment.equipmentName)
                        .multilineTextAlignment(.trailing)
                }
                Picker(selection: $equipment.equipmentSize, label: Text("Size")) {
                    ForEach(Equipment.Size.allCases) { size in
                        Text(size.rawValue)
                            .tag(size)
                    }
                }
                FormDatePicker(label: "Purchase Date",
                               date: $equipment.purchaseDate)
            }
            Section(header: Text("Check cycle")) {
                CheckCycleRow(checkCycle: $equipment.floatingCheckCycle)
            }
            if equipment.isInserted {
                Section(header: Text("Next steps")) {
                    Button(action: { showingLogCheck.toggle() }) {
                        HStack {
                            FormIcon(icon: Image(systemName: "checkmark.circle.fill"))
                                .padding(.trailing, 8)
                            Text("Log last check")
                            Spacer()
                            if lastCheckDate != nil {
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
                            if manualURL != nil {
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
                    managedObjectContext.rollback()
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    if let date = lastCheckDate {
                        let check = Check.create(context: managedObjectContext, date: date)
                        equipment.addToCheckLog(check)
                    }

                    if let url = manualURL {
                        do {
                            let data = try Data(contentsOf: url)
                            let manual = Manual(context: managedObjectContext)
                            manual.data = data
                            equipment.manual = manual
                        } catch {
                            // TODO: error handling
                            print(error)
                        }
                    }

                    try! managedObjectContext.save()
                    dismiss()
                }
                .disabled(equipment.equipmentBrand == .none || equipment.equipmentName.isEmpty)
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

    static let persistentContainer = NSPersistentContainer.fake(name: "Model")

    static var equipments: [Equipment] {
        persistentContainer.fakeProfile().equipment!.allObjects as! [Equipment]
    }

    static var previews: some View {
        Group {
            NavigationView {
                EditEquipmentView(equipment: equipments[0])
            }

            NavigationView {
                EditEquipmentView(equipment: Paraglider(context: persistentContainer.viewContext))
            }

            NavigationView {
                EditEquipmentView(equipment: equipments[1])
            }
        }
        .environment(\.locale, .init(identifier: "de"))
        .environment(\.managedObjectContext, persistentContainer.viewContext)
    }
}
