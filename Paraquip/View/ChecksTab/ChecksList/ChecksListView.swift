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
    let profile: Profile?

    private var noChecksText: LocalizedStringKey {
        if let profile {
            let icon = Image(systemName: profile.profileIcon.systemName)
            return "No checks in \(icon) \(profile.profileName)"
        } else {
            return "No checks available"
        }
    }

    var body: some View {
        if checks.isEmpty {
            ContentUnavailableView(noChecksText,
                                   systemImage: "checkmark.circle.fill")
        } else {
            List {
                ForEach(checks.sections) { section in
                    if !section.equipment.isEmpty {
                        Section {
                            ForEach(section.equipment) { equipment in
                                NavigationLink(value: equipment) {
                                    CheckButtonLabel(equipment: equipment)
                                }
                                .foregroundStyle(.primary)
                            }
                        } header: {
                            section.titleText
                        }
                    }
                }
            }
            .navigationDestination(for: Equipment.self) { equipment in
                LogSheet(equipment: equipment)
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
    NavigationStack {
        ChecksListView(checks: CheckList(equipment: CoreData.fakeProfile.allEquipment),
                       profile: CoreData.fakeProfile)
    }
}
