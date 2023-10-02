//
//  ChecksListView.swift
//  Paraquip
//
//  Created by Simon Seyer on 01.10.23.
//

import SwiftUI

private extension CheckSection {
    @ViewBuilder
    var titleText: some View {
        switch title {
        case .month(let date):
            Text(date, format: .dateTime.month(.wide))
        case .now:
            Text("\(Image(systemName: "hourglass")) Now")
        case .later:
            Text("\(Image(systemName: "clock")) Later")
        }
    }
}

struct ChecksListView: View {

    let checks: CheckList

    @State private var showInspector: Bool = false
    @State private var selectedEquipment: Equipment? = nil

    var body: some View {
        if checks.isEmpty {
            ContentUnavailableView("No checks available", systemImage: "checkmark.circle.fill")
        } else {
            List {
                ForEach(checks.sections) { section in
                    if !section.equipment.isEmpty {
                        Section {
                            ForEach(section.equipment) { equipment in
                                Button {
                                    withAnimation {
                                        selectedEquipment = equipment
                                        showInspector = true
                                    }
                                } label: {
                                    CheckButtonLabel(equipment: equipment)
                                }
                                .listRowBackground(selectedEquipment == equipment ? Color(uiColor: .systemFill) : nil)
                                .foregroundStyle(.primary)
                            }
                        } header: {
                            section.titleText
                        }
                    }
                }
            }
            #if os(iOS)
            .inspector(isPresented: $showInspector) {
                if let selectedEquipment {
                    LogSheet(equipment: selectedEquipment)
                }
            }
            #endif
            .onChange(of: showInspector) {
                if !showInspector {
                    withAnimation {
                        selectedEquipment = nil
                    }
                }
            }
        }
    }
}

private struct CheckButtonLabel: View {

    @ObservedObject var equipment: Equipment

    var body: some View {
        HStack(spacing: 18) {
            equipment.checkUrgency.icon
                .frame(width: 25, height: 25)
                .background(
                    Circle()
                        .fill(equipment.checkUrgency.color)
                )
                .foregroundStyle(.white)
            VStack(alignment: .leading) {
                let brandText = Text(equipment.brandName).fontWeight(.light)
                Text("\(brandText) \(Text(equipment.equipmentName))")
                Text(equipment.checkUrgency.formattedCheckInterval)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    ChecksListView(checks: CheckList(equipment: CoreData.fakeProfile.allEquipment))
}
