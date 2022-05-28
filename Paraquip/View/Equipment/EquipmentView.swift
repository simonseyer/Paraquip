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

    @State private var editEquipmentOperation: Operation<Equipment>?
    @State private var editLogEntryOperation: Operation<LogEntry>?
    @State private var createLogEntryOperation: Operation<LogEntry>?
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
                    createLogEntryOperation = Operation(withParentContext: managedObjectContext)
                }
                ForEach(checkLog) { logEntry in
                    LogEntryCell(logEntry: logEntry) {
                        editLogEntryOperation = Operation(editing: logEntry,
                                                          withParentContext: managedObjectContext)
                    }
                }
                if let purchaseLog = equipment.purchaseLog {
                    LogEntryCell(logEntry: purchaseLog) {
                        editLogEntryOperation = Operation(editing: purchaseLog,
                                                          withParentContext: managedObjectContext)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .toolbar {
                Button("Edit") {
                    editEquipmentOperation = Operation(editing: equipment,
                                                       withParentContext: managedObjectContext)
                }
            }
            .navigationTitle(equipment.equipmentName)
            .sheet(item: $editEquipmentOperation) { operation in
                NavigationView {
                    EditEquipmentView(equipment: operation.object, locale: locale)
                        .environment(\.managedObjectContext, operation.childContext)
                }
            }
            .sheet(item: $editLogEntryOperation) { operation in
                NavigationView {
                    LogEntryView(logEntry: operation.object)
                        .environment(\.managedObjectContext, operation.childContext)
                        .navigationTitle(operation.object.isPurchase ? "Purchase" : "Check")
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Delete") {
                                    operation.childContext.delete(operation.object)
                                    try! operation.childContext.save()
                                    editLogEntryOperation = nil
                                }
                            }
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Save") {
                                    try! operation.childContext.save()
                                    editLogEntryOperation = nil
                                }
                            }
                        }
                }
            }
            .sheet(item: $createLogEntryOperation) { operation in
                NavigationView {
                    LogEntryView(logEntry: operation.object)
                        .navigationTitle(operation.object.isPurchase ? "Purchase" : "Check")
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Cancel") {
                                    createLogEntryOperation = nil
                                }
                            }
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Log") {
                                    operation.object(for: equipment).addToCheckLog(operation.object)
                                    try! operation.childContext.save()
                                    createLogEntryOperation = nil
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
