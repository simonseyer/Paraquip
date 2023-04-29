//
//  EditEquipmentView.swift
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

struct EditEquipmentView: View {

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
    @Environment(\.dismiss) private var dismiss

    @State private var editLogEntryOperation: Operation<LogEntry>?
    @State private var showingManualPicker = false
    @State private var isShowingRecommendedWeightRange: Bool
    @State private var isShowingValidationAlert = false
    @State private var validationAlertMessage: LocalizedStringKey?
    @FocusState private var focusedField: Field?

    private let initialFocusedField: Field?

    private var isMaxWeightValid: Bool {
        equipment.maxWeightValue ?? .greatestFiniteMagnitude >= equipment.minWeightValue ?? 0
    }

    private var isRecommendedWeightValid: Bool {
        guard isMaxWeightValid else { return true }
        let min = equipment.minWeightValue ?? 0
        let max = equipment.maxWeightValue ?? .greatestFiniteMagnitude
        let minRecommended = equipment.minRecommendedWeightValue ?? min
        let maxRecommended = equipment.maxRecommendedWeightValue ?? max
        return minRecommended >= min && maxRecommended >= minRecommended && maxRecommended <= max
    }

    private var maxWeightValidationColor: UIColor {
        if [.minimumWeight, .maximumWeight].contains(focusedField) {
            return .systemGray
        } else {
            return .systemRed
        }
    }

    private var recommendedWeightValidationColor: UIColor {
        if [.minimumRecommendedWeight, .maximumRecommendedWeight].contains(focusedField) {
            return .systemGray
        } else {
            return .systemRed
        }
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

    private var title: Text {
        let type = LocalizedString(equipment.equipmentType.localizedNameString)
        if !equipment.brandName.isEmpty {
            return Text("\(equipment.brandName) \(type)")
        } else {
            return Text(type)
        }
    }

    init(equipment: Equipment, focusedField: Field? = nil) {
        self.equipment = equipment
        self.initialFocusedField = focusedField
        _isShowingRecommendedWeightRange = .init(initialValue: equipment.hasRecommendedWeightRange)
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
                    }.foregroundColor(.primary)
                }
                .swipeActions {
                    if equipment.purchaseLog != nil {
                        Button {
                            equipment.purchaseLog = nil
                        } label: {
                            Label("Clear", systemImage: "clear")
                        }
                    }
                }
                .labelStyle(.titleOnly)
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
                        if !isMaxWeightValid {
                            Button("\(Image(systemName: "exclamationmark.triangle.fill"))") {
                                withAnimation {
                                    validationAlertMessage = "The maximum weight must be larger then the mimimum weight."
                                    isShowingValidationAlert.toggle()
                                }
                            }
                            .buttonStyle(.plain)
                            .foregroundColor(Color(maxWeightValidationColor))
                        }
                    }
                } footer: {
                    if equipment is Paraglider && !isShowingRecommendedWeightRange {
                        Button("\(Image(systemName: "plus")) Recommended weight range") {
                            withAnimation {
                                isShowingRecommendedWeightRange.toggle()
                            }
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(.accentColor)
                    }
                }
            }
            if isShowingRecommendedWeightRange {
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
                    HStack {
                        Text("Recommended weight range")
                        Button("\(Image(systemName: "minus.circle.fill"))") {
                            withAnimation {
                                // TODO: fix value not cleared when field selected
                                equipment.clearRecommendedWeightRange()
                                isShowingRecommendedWeightRange.toggle()
                            }
                        }.buttonStyle(.plain)
                        Spacer()
                        if !isRecommendedWeightValid {
                            Button("\(Image(systemName: "exclamationmark.triangle.fill"))") {
                                withAnimation {
                                    validationAlertMessage = "The recommended weight range must lie within the certified weight range."
                                    isShowingValidationAlert.toggle()
                                }
                            }
                            .buttonStyle(.plain)
                            .foregroundColor(Color(recommendedWeightValidationColor))
                        }
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
            if equipment.isCheckable {
                Section(header: Text("Check cycle")) {
                    CheckCycleRow(checkCycle: $equipment.floatingCheckCycle)
                }
            }
            if equipment.isInserted {
                Section(header: Text("Next steps")) {
                    if equipment.isCheckable {
                        Button(action: {
                            if let logEntry = equipment.allChecks.first {
                                editLogEntryOperation = Operation(editing: logEntry,
                                                                  withParentContext: managedObjectContext)
                            } else {
                                let operation = Operation<LogEntry>(withParentContext: managedObjectContext)
                                operation.object(for: equipment).addToCheckLog(operation.object)
                                editLogEntryOperation = operation
                            }
                        }) {
                            HStack {
                                FormIcon(icon: Image(systemName: "checkmark.circle.fill"))
                                    .padding(.trailing, 8)
                                Text("Log last check")
                                Spacer()
                                if !equipment.allChecks.isEmpty {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Color.green)
                                }
                            }
                            .foregroundColor(.primary)
                        }
                    }

                    Button(action: { showingManualPicker = true }) {
                        HStack {
                            FormIcon(icon: Image(systemName: "book.fill"))
                                .padding(.trailing, 8)
                            Text("Attach Manual")
                            Spacer()
                            if equipment.manualAttachment != nil {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color.green)
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button("Done") {
                    focusedField = nil
                }
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    try! managedObjectContext.save()
                    dismiss()
                }
                .disabled(
                    equipment.brandName.isEmpty ||
                    equipment.equipmentName.isEmpty ||
                    !isMaxWeightValid ||
                    !isRecommendedWeightValid)
            }
        }
        .sheet(item: $editLogEntryOperation) { operation in
            NavigationView {
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
        .alert("Invalid weight range", isPresented: $isShowingValidationAlert, presenting: $validationAlertMessage) { _ in
            Button("Ok", role: .cancel) { }
        } message: { message in
            if let message = message.wrappedValue {
                Text(message)
            }
        }
        .onAppear {
            if let initialFocusedField {
                focusedField = initialFocusedField
            } else if equipment.isInserted {
                focusedField = .brand
            }
        }
    }
}

struct AddEquipmentView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            NavigationStack {
                EditEquipmentView(equipment: Paraglider.create(context: .preview),
                                  focusedField: .minimumWeight)
            }
            ForEach(CoreData.fakeProfile.allEquipment) { equipment in
                NavigationStack {
                    EditEquipmentView(equipment: equipment,
                                      focusedField: .minimumWeight)
                }
                .previewDisplayName(equipment.equipmentName)
            }
        }
        .environment(\.managedObjectContext, .preview)
    }
}
