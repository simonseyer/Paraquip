//
//  CheckUrgencyViewExtensions.swift
//  Paraquip
//
//  Created by Simon Seyer on 23.08.21.
//

import Foundation
import SwiftUI

extension Equipment.CheckUrgency {
    private static let dateFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 1
        formatter.allowedUnits = [.month, .day]
        formatter.includesTimeRemainingPhrase = true
        return formatter
    }()

    var formattedCheckInterval: LocalizedStringKey {
        switch self {
        case .now:
            return "Check now"
        case .soon(let date), .later(let date):
            return "\(Self.dateFormatter.string(from: Date.paraquipNow, to: date) ?? "")"
        case .never:
            return "No check needed"
        }
    }

    var icon: some View {
        switch self {
        case .now, .soon:
            return Image(systemName: "exclamationmark")
                .font(.system(size: 13, weight: .heavy))
        case .later, .never:
            return Image(systemName: "checkmark")
                .font(.system(size: 12, weight: .bold))
        }
    }

    var color: Color {
        switch self {
        case .now:
            return .red
        case .soon:
            return .orange
        case .later, .never:
            return .green
        }
    }
}
