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

    var color: Color {
        switch self {
        case .now:
            return Color(UIColor.systemRed)
        case .soon:
            return Color(UIColor.systemOrange)
        case .later, .never:
            return Color(UIColor.systemGreen)
        }
    }

    var icon: Image {
        switch self {
        case .now:
            return Image(systemName: "exclamationmark.circle.fill")
        case .soon:
            return Image(systemName: "exclamationmark.triangle.fill")
        case .later, .never:
            return Image(systemName: "checkmark.circle.fill")
        }
    }
}
