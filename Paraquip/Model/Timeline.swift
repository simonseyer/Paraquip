//
//  Timeline.swift
//  Paraquip
//
//  Created by Simon Seyer on 23.08.21.
//

import Foundation

enum TimelineEntry {
    case purchase(date: Date)
    case check(check: Check)
    case nextCheck(urgency: Equipment.CheckUrgency)
}

extension Equipment {
    var timeline: [TimelineEntry] {
        var timeline: [TimelineEntry] = []

        timeline.append(.nextCheck(urgency: checkUrgency))

        timeline.append(contentsOf: sortedCheckLog.map {
            .check(check: $0)
        })

        if let purchaseDate = purchaseDate {
            timeline.append(.purchase(date: purchaseDate))
        }

        return timeline
    }
}
