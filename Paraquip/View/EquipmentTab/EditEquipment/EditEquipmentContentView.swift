//
//  EditEquipmentContentView.swift
//  Paraquip
//
//  Created by Simon Seyer on 18.04.21.
//

import SwiftUI
import CoreData

extension NumberFormatter {
    func string(from doubleValue: Double) -> String? {
        return string(from: NSNumber(value: doubleValue))
    }

    func value(from string: String) -> Double? {
        return number(from: string)?.doubleValue
    }
}

fileprivate struct LogDateCell: View {

    @ObservedObject var logEntry: LogEntry

    var body: some View {
        HStack {
            if !logEntry.logEntryAttachments.isEmpty {
                Image(systemName: "paperclip")
            }
            Text(logEntry.logEntryDate, format: Date.FormatStyle(date: .abbreviated, time: .omitted))
        }
        .foregroundColor(.secondary)
    }
}

struct EditEquipmentContentView: View {

    enum Field {
        case brand
        case name
        case size
        case weight
        case purchaseDate
        case minimumWeight
        case maximumWeight
        case minimumRecommendedWeight
        case maximumRecommendedWeight
        case projectedArea
    }

    @ObservedObject var equipment: Equipment

    @Environment(\.managedObjectContext) private var managedObjectContext

    @State private var editLogEntryOperation: Operation<LogEntry>?
    @State private var showingManualPicker = false
    @State private var previewedManual: URL? = nil
    @State private var isShowingRecommendedWeightRange: Bool
    @State private var isShowingValidationAlert = false
    @State private var isShowingDeleteEquipment = false
    @State private var validationAlertMessage: LocalizedStringKey?
    @State private var undoHandler: UndoHandler<Bool>?
    @State private var canUndo = false
    @State private var canRedo = false
    @FocusState private var focusedField: Field?

    private let undoManager = UndoManager()
    private let undoObserver = NotificationCenter.default.publisher(for: .NSUndoManagerDidCloseUndoGroup)

    private var isMaxWeightValid: Bool {
        equipment.maxWeightValue ?? .greatestFiniteMagnitude >= equipment.minWeightValue ?? 0
    }

    private var isRecommendedWeightValid: Bool {
        let min = equipment.minWeightValue ?? 0
        let max = equipment.maxWeightValue ?? .greatestFiniteMagnitude
        let minRecommended = equipment.minRecommendedWeightValue ?? min
        let maxRecommended = equipment.maxRecommendedWeightValue ?? max
        return minRecommended >= min && maxRecommended >= minRecommended && maxRecommended <= max
    }

    private var weightRangeFormat: FloatingPointFormatStyle<Double> {
        .number.precision(.fractionLength(0))
    }

    private var formattedMinWeight: String {
        equipment.minWeightValue?.formatted(weightRangeFormat) ?? ""
    }

    private var formattedMaxWeight: String {
        equipment.maxWeightValue?.formatted(weightRangeFormat) ?? ""
    }

    init(equipment: Equipment) {
        self.equipment = equipment
        _isShowingRecommendedWeightRange = .init(initialValue: equipment.hasRecommendedWeightRange)
    }

    private var clearLabel: some View {
        Label("Clear", systemImage: "xmark.circle")
            #if os(visionOS)
            .labelStyle(.titleOnly)
            #else
            .labelStyle(.iconOnly)
            #endif
    }

    var body: some View {
        Form {
            Section(header: Text("")) {
                AutocompletingTextField("Brand", text: $equipment.brandName, completions: Equipment.brandSuggestions)
                    .focused($focusedField, equals: .brand)
                HStack {
                    Text("Name")
                    Spacer()
                    TextField("", text: $equipment.equipmentName)
                        .multilineTextAlignment(.trailing)
                        .autocorrectionDisabled()
                        .focused($focusedField, equals: .name)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .size }
                }
                AutocompletingTextField("Size", text: $equipment.equipmentSize, completions: Equipment.sizeSuggestions)
                    .textInputAutocapitalization(.characters)
                    .focused($focusedField, equals: .size)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .weight }
                HStack {
                    Text("Weight")
                    Spacer()
                    TextField("", value: $equipment.weightValue, format: .number.precision(.fractionLength(1...2)))
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .weight)
                    Text("kg")
                        .foregroundColor(.secondary)
                }
                Button(action: {
                    if let logEntry = equipment.purchaseLog {
                        editLogEntryOperation = Operation(editing: logEntry,
                                                          withParentContext: managedObjectContext)
                    } else {
                        let operation = Operation<LogEntry>(withParentContext: managedObjectContext)
                        operation.object(for: equipment).purchaseLog = operation.object
                        editLogEntryOperation = operation
                    }
                }) {
                    LabeledContent("Purchase") {
                        if let purchaseLog = equipment.purchaseLog {
                            LogDateCell(logEntry: purchaseLog)
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
            Section {
                if let manual = equipment.manualAttachment {
                    Button {
                        previewedManual = manual.fileURL
                    } label: {
                        Label("Open manual", systemImage: "book")
                    }
                } else {
                    Button(action: {
                        showingManualPicker = true
                    }) {
                        Label("Add manual",
                              systemImage: "plus.circle")
                    }
                }
            } header: {
                HStack(spacing: 12) {
                    Text("Manual")
                    Button(action: {
                        withAnimation {
                            equipment.manualAttachment = nil
                        }
                    }) {
                        clearLabel
                    }
                    .controlSize(.mini)
                    .opacity(equipment.manualAttachment == nil ? 0 : 1)
                }
            }
            if equipment is Paraglider || equipment is Reserve {
                Section {
                    if equipment is Paraglider {
                        HStack {
                            Text("Minimum")
                            Spacer()
                            TextField("", value: $equipment.minWeightValue, format: weightRangeFormat)
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.numberPad)
                                .focused($focusedField, equals: .minimumWeight)
                                .submitLabel(.next)
                                .onSubmit { focusedField = .maximumWeight }
                            Text("kg")
                                .foregroundColor(.secondary)
                        }
                    }
                    HStack {
                        Text("Maximum")
                        Spacer()
                        TextField("", value: $equipment.maxWeightValue, format: weightRangeFormat)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                            .focused($focusedField, equals: .maximumWeight)
                            .submitLabel(.next)
                            .onSubmit {
                                if isShowingRecommendedWeightRange {
                                    focusedField = .minimumRecommendedWeight
                                } else {
                                    focusedField = .projectedArea
                                }
                            }
                        Text("kg")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    HStack {
                        Text("Weight range")
                        Spacer()
                        Button {
                            validationAlertMessage = "The maximum weight must be larger then the mimimum weight."
                            isShowingValidationAlert.toggle()
                        } label: {
                            Image(systemName: "exclamationmark.triangle")
                        }
                        .controlSize(.mini)
                        .foregroundStyle(.red)
                        .opacity(isMaxWeightValid ? 0 : 1)
                        .animation(.default, value: isMaxWeightValid)
                    }
                } footer: {
                    if equipment is Paraglider && !isShowingRecommendedWeightRange {
                        Button("\(Image(systemName: "plus")) Recommended weight range") {
                            withAnimation {
                                isShowingRecommendedWeightRange.toggle()
                            }
                        }
                        .controlSize(.small)
                    }
                }
            }
            if equipment is Paraglider && isShowingRecommendedWeightRange {
                Section {
                    HStack {
                        Text("Minimum")
                        Spacer()
                        TextField(formattedMinWeight, value: $equipment.minRecommendedWeightValue, format: weightRangeFormat)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                            .focused($focusedField, equals: .minimumRecommendedWeight)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .maximumRecommendedWeight }
                        Text("kg")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Maximum")
                        Spacer()
                        TextField(formattedMaxWeight, value: $equipment.maxRecommendedWeightValue, format: weightRangeFormat)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                            .focused($focusedField, equals: .maximumRecommendedWeight)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .projectedArea }
                        Text("kg")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    HStack(spacing: 12) {
                        Text("Recommended weight range")
                        Button {
                            withAnimation {
                                equipment.clearRecommendedWeightRange()
                                isShowingRecommendedWeightRange.toggle()
                            }
                        } label: {
                            clearLabel
                        }.controlSize(.mini)
                        Spacer()
                        Button("\(Image(systemName: "exclamationmark.triangle"))") {
                            validationAlertMessage = "The recommended weight range must lie within the certified weight range."
                            isShowingValidationAlert.toggle()
                        }
                        .controlSize(.mini)
                        .foregroundStyle(.red)
                        .opacity(isRecommendedWeightValid ? 0 : 1)
                        .animation(.default, value: isRecommendedWeightValid)
                    }
                }
            }
            if equipment is Paraglider {
                Section(header: Text("Specifications")) {
                    HStack {
                        Text("Projected area")
                        Spacer()
                        TextField("", value: $equipment.projectedAreaValue, format: .number.precision(.fractionLength(0)))
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .projectedArea)
                        Text("m²")
                            .foregroundColor(.secondary)
                    }
                }
            }
            Section(header: Text("Check cycle")) {
                CheckCycleRow(checkCycle: $equipment.floatingCheckCycle)
            }
            Button(role: .destructive) {
                isShowingDeleteEquipment = true
            } label: {
                Label("Delete equipment",
                      systemImage: "trash")
                .foregroundStyle(.red)
            }
            .confirmationDialog("Delete equipment", isPresented: $isShowingDeleteEquipment) {
                Button(role: .destructive) {
                    withAnimation {
                        managedObjectContext.delete(equipment)
                    }
                } label: {
                    Text("Delete")
                }
            }
        }
        #if os(iOS)
        .scrollDismissesKeyboard(.interactively)
        .symbolVariant(.fill)
        #endif
        .navigationTitle(Text(equipment.equipmentType.localizedName))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $editLogEntryOperation) { operation in
            NavigationStack {
                LogEntryView(logEntry: operation.object)
                    .environment(\.managedObjectContext, operation.childContext)
            }
        }
        .sheet(isPresented: $showingManualPicker) {
            DocumentPicker(contentTypes: [.pdf]) { url in
                let attachment = Attachment.create(fileURL: url,
                                                   context: managedObjectContext)
                equipment.manualAttachment = attachment
            }
        }
        .quickLookPreview($previewedManual)
        .alert("Invalid weight range", isPresented: $isShowingValidationAlert, presenting: $validationAlertMessage) { _ in
            Button("Ok", role: .cancel) { }
        } message: { message in
            if let message = message.wrappedValue {
                Text(message)
            }
        }
        .onChange(of: isShowingRecommendedWeightRange) {  oldValue, newValue in
            undoHandler?.registerUndo(from: oldValue, to: newValue)
        }
        .onChange(of: undoManager, initial: true) {
            undoHandler = UndoHandler(binding: $isShowingRecommendedWeightRange,
                                      undoManger: undoManager)
            managedObjectContext.undoManager = undoManager
            updateUndoState()
        }
        .onReceive(undoObserver) { _ in
            updateUndoState()
        }
        .toolbar {
            ToolbarItem {
                Button {
                    withAnimation {
                        undoManager.undo()
                        updateUndoState()
                    }
                } label: {
                    Label("Undo", systemImage: "arrow.uturn.backward")
                }
                .keyboardShortcut(KeyEquivalent("z"), modifiers: [.command])
                .disabled(!canUndo)
            }
            ToolbarItem {
                Button {
                    withAnimation {
                        undoManager.redo()
                        updateUndoState()
                    }
                } label: {
                    Label("Redo", systemImage: "arrow.uturn.forward")
                }
                .keyboardShortcut(KeyEquivalent("z"), modifiers: [.command, .shift])
                .disabled(!canRedo)
            }
        }
    }

    private func updateUndoState() {
        canUndo = undoManager.canUndo
        canRedo = undoManager.canRedo
    }
}

#Preview("New Paraglider") {
    NavigationStack {
        EditEquipmentContentView(equipment: Paraglider.create(context: .preview))
    }
}

#Preview("Paraglider") {
    NavigationStack {
        EditEquipmentContentView(equipment: CoreData.fakeProfile.paraglider!)
    }
    .environment(\.managedObjectContext, .preview)
}

#Preview("Harness") {
    NavigationStack {
        EditEquipmentContentView(equipment: CoreData.fakeProfile.singleEquipment(of: .harness)!)
    }
    .environment(\.managedObjectContext, .preview)
}

#Preview("Reserve") {
    NavigationStack {
        EditEquipmentContentView(equipment: CoreData.fakeProfile.singleEquipment(of: .reserve)!)
    }
    .environment(\.managedObjectContext, .preview)
}
