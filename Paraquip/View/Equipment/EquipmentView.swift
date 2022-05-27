//
//  EquipmentView.swift
//  Paraquip
//
//  Created by Simon Seyer on 18.04.21.
//

import SwiftUI
import CoreData

struct EquipmentView: View {

    @ObservedObject var equipment: Equipment
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.locale) var locale: Locale

    @State private var showingEditEquipment = false
    @State private var editLogEntry: LogEntry?
    @State private var showingManual = false

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()

    @FetchRequest
    private var checkLog: FetchedResults<LogEntry>

    init(equipment: Equipment) {
        self.equipment = equipment
        _checkLog = FetchRequest<LogEntry>(sortDescriptors: [SortDescriptor(\.date, order: .reverse)],
                                        predicate: NSPredicate(format: "%K == %@", #keyPath(LogEntry.equipment), equipment))
    }

    var body: some View {
        VStack(alignment: .leading) {
            EquipmentHeaderView(brandName: equipment.brandName,
                            icon: equipment.icon,
                            showManualAction: { showingManual.toggle() }) {
                HStack {
                    PillLabel(LocalizedStringKey(equipment.localizedType))
                    if let size = equipment.size {
                        PillLabel("Size \(size)")
                    }
                }
            }

            List {
                NextCheckCell(urgency: equipment.checkUrgency) {
                    editLogEntry = LogEntry.create(context: managedObjectContext)
                }
                ForEach(checkLog) { logEntry in
                    LogEntryCell(logEntry: logEntry) {
                        self.editLogEntry = logEntry
                    }
                }
                if let purchaseLog = equipment.purchaseLog {
                    LogEntryCell(logEntry: purchaseLog) {
                        editLogEntry = purchaseLog
                    }
                }
            }
            .listStyle(.insetGrouped)
            .toolbar {
                Button("Edit") {
                    showingEditEquipment = true
                }
            }
            .navigationTitle(equipment.equipmentName)
            .sheet(isPresented: $showingEditEquipment) {
                NavigationView {
                    EditEquipmentView(equipment: equipment, locale: locale)
                }
            }
            .sheet(item: $editLogEntry, onDismiss: {
                managedObjectContext.rollback()
            }) { check in
                NavigationView {
                    if check.isTemporary {
                        LogEntryView(logEntry: check)
                            .navigationTitle(check.isPurchase ? "Purchase" : "Check")
                            .toolbar {
                                ToolbarItem(placement: .cancellationAction) {
                                    Button("Cancel") {
                                        managedObjectContext.delete(check)
                                        try! managedObjectContext.save()
                                        editLogEntry = nil
                                    }
                                }
                                ToolbarItem(placement: .confirmationAction) {
                                    Button("Log") {
                                        equipment.addToCheckLog(check)
                                        try! managedObjectContext.save()
                                        editLogEntry = nil
                                    }
                                }
                            }
                    } else {
                        LogEntryView(logEntry: check)
                            .navigationTitle(check.isPurchase ? "Purchase" : "Check")
                            .toolbar {
                                ToolbarItem(placement: .cancellationAction) {
                                    Button("Delete") {
                                        managedObjectContext.delete(check)
                                        try! managedObjectContext.save()
                                        editLogEntry = nil
                                    }
                                }
                                ToolbarItem(placement: .confirmationAction) {
                                    Button("Save") {
                                        try! managedObjectContext.save()
                                        editLogEntry = nil
                                    }
                                }
                            }
                    }
                }
            }
            .sheet(isPresented: $showingManual) {
                if let manual = equipment.manual {
                    NavigationView {
                        ManualView(manual: manual.data!, deleteManual: {
                            managedObjectContext.delete(manual)
                            try! managedObjectContext.save()
                        })
                    }
                } else {
                    DocumentPicker(contentTypes: [.pdf]) { url in
                        do {
                            let data = try Data(contentsOf: url)
                            let manual = Manual(context: managedObjectContext)
                            manual.data = data
                            equipment.manual = manual
                            try managedObjectContext.save()
                        } catch {
                            // TODO: error handling
                            print(error)
                        }
                    }
                }
            }
        }
    }
}

struct EquipmentView_Previews: PreviewProvider {

    static var previews: some View {
        ForEach(CoreData.fakeProfile.allEquipment) { equipment in
            NavigationView {
                EquipmentView(equipment: equipment)
            }
        }
        .environment(\.locale, .init(identifier: "de"))
        .environment(\.managedObjectContext, CoreData.previewContext)
    }
}
