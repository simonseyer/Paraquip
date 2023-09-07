//
//  EquipmentView.swift
//  Paraquip
//
//  Created by Simon Seyer on 18.04.21.
//

import SwiftUI
import CoreData
import QuickLook

struct EquipmentView: View {

    @ObservedObject var equipment: Equipment
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.locale) var locale: Locale

    @State private var editLogEntryOperation: Operation<LogEntry>?
    @State private var editEquipmentOperation: Operation<Equipment>?
    @State private var isDeletingManual = false
    @State private var previewedManual: URL? = nil
    @State private var showingManualPicker = false

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
            if UIDevice.current.userInterfaceIdiom == .phone {
                EquipmentHeaderView(brandName: equipment.brandName,
                                    icon: equipment.icon) {
                    HStack {
                        PillLabel(equipment.equipmentType.localizedName)
                        if let size = equipment.size {
                            PillLabel("Size \(size)")
                        }
                    }
                }
            }

            List {
                if equipment.isCheckable || equipment.purchaseLog != nil || !checkLog.isEmpty {
                    Section {
                        if equipment.isCheckable {
                            NextCheckCell(urgency: equipment.checkUrgency) {
                                let operation = Operation<LogEntry>(withParentContext: managedObjectContext)
                                operation.object(for: equipment).addToCheckLog(operation.object)
                                editLogEntryOperation = operation
                            }
                        }
                        ForEach(checkLog) { logEntry in
                            LogEntryCell(logEntry: logEntry) {
                                editLogEntry(logEntry)
                            } onDelete: {
                                deleteLogEntry(logEntry)
                            }

                        }
                        
                        if let logEntry = equipment.purchaseLog {
                            LogEntryCell(logEntry: logEntry) {
                                editLogEntry(logEntry)
                            } onDelete: {
                                deleteLogEntry(logEntry)
                            }
                        }
                    }
                }
                Section {
                    Button(action: {
                        if let manual = equipment.manualAttachment {
                            previewedManual = manual.fileURL
                        } else {
                            showingManualPicker = true
                        }
                    }) {
                        HStack {
                            Image(systemName: equipment.manualAttachment != nil ? "book.fill" : "book")
                            Text("Manual")
                        }
                    }
                    .foregroundStyle(.primary)
                    .confirmationDialog(Text("Delete manual"), isPresented: $isDeletingManual) {
                        Button("Delete", role: .destructive) {
                            withAnimation {
                                equipment.manualAttachment = nil
                                try? managedObjectContext.save()
                            }
                        }
                        Button("Cancel", role: .cancel) {}
                    }
                    .contextMenu {
                        if equipment.manualAttachment != nil {
                            Button(role: .destructive) {
                                isDeletingManual = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(equipment.equipmentName)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button(action: {
                        editEquipmentOperation = Operation(editing: equipment,
                                                         withParentContext: managedObjectContext)
                    }) {
                        Label("Edit", systemImage: "pencil")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(item: $editLogEntryOperation) { operation in
            NavigationStack {
                LogEntryView(logEntry: operation.object)
                    .environment(\.managedObjectContext, operation.childContext)
            }
        }
        .sheet(item: $editEquipmentOperation) { operation in
            NavigationStack {
                EditEquipmentView(equipment: operation.object)
                    .environment(\.managedObjectContext, operation.childContext)
            }
        }
        .quickLookPreview($previewedManual)
        .sheet(isPresented: $showingManualPicker) {
            DocumentPicker(contentTypes: [.pdf]) { url in
                withAnimation {
                    let attachment = Attachment.create(fileURL: url,
                                                       context: managedObjectContext)
                    equipment.manualAttachment = attachment
                    try? managedObjectContext.save()
                }
            }

        }
    }

    private func editLogEntry(_ logEntry: LogEntry) {
        editLogEntryOperation = Operation(editing: logEntry,
                                          withParentContext: managedObjectContext)
    }

    private func deleteLogEntry(_ logEntry: LogEntry) {
        withAnimation {
            managedObjectContext.delete(logEntry)
            try! managedObjectContext.save()
        }
    }
}

struct EquipmentView_Previews: PreviewProvider {

    static var previews: some View {
        ForEach(CoreData.fakeProfile.allEquipment) { equipment in
            NavigationStack {
                EquipmentView(equipment: equipment)
            }
            .previewDisplayName(equipment.equipmentName)
        }
        .environment(\.locale, .init(identifier: "de"))
        .environment(\.managedObjectContext, .preview)
    }
}
