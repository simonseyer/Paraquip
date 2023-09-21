//
//  LogEntryBackground.swift
//  Paraquip
//
//  Created by Simon Seyer on 21.09.23.
//

import SwiftUI

struct LogEntryBackground: View {

    enum Position {
        case start, middle, end
    }

    let color: Color?
    let position: Position
    let icon: String?

    private let center = 38.0
    private let lineWidth = 4.0
    private var leadingLinePadding: Double {
        center - lineWidth / 2
    }
    private var circleDiameter: CGFloat {
        icon != nil ? 34 : 16
    }

    private var foregroundStyle: some ShapeStyle {
        if let color {
            return AnyShapeStyle(color)
        } else {
            #if os(visionOS)
            return AnyShapeStyle(.regularMaterial)
            #else
            return AnyShapeStyle(Color(uiColor: .tertiarySystemFill))
            #endif
        }
    }

    @ViewBuilder
    private func lineView(metrics: GeometryProxy) -> some View {
        Rectangle()
            .frame(
                width: lineWidth,
                height: max(0, (metrics.size.height - circleDiameter) / 2))
            .foregroundStyle(foregroundStyle)
    }

    var body: some View {
        GeometryReader { metrics in
            ZStack(alignment: .topLeading) {
                if [.end, .middle].contains(position) {
                    lineView(metrics: metrics)
                        .padding(.leading, leadingLinePadding)
                }

                ZStack {
                    Circle()
                        .frame(width: circleDiameter, height: circleDiameter)
                        .foregroundStyle(foregroundStyle)
                    if let icon {
                        Image(systemName: icon)
                            .font(.system(size: 12, weight: .bold))
                    }
                }
                .padding(EdgeInsets(top: metrics.size.height / 2 - (circleDiameter / 2),
                                    leading: center - (circleDiameter / 2.0),
                                    bottom: 0,
                                    trailing: 0))

                if [.start, .middle].contains(position) {
                    lineView(metrics: metrics)
                        .padding(EdgeInsets(top: (metrics.size.height + circleDiameter) / 2,
                                            leading: leadingLinePadding,
                                            bottom: 0,
                                            trailing: 0))
                }
            }

        }
    }
}

#Preview {
    VStack(spacing: 0) {
        LogEntryBackground(color: .green, position: .start, icon: nil)
        LogEntryBackground(color: nil, position: .middle, icon: "hourglass")
        LogEntryBackground(color: nil, position: .middle, icon: "tent")
        LogEntryBackground(color: nil, position: .end, icon: "dollarsign")
    }
    .frame(width: 76, height: 300)
    #if os(visionOS)
    .glassBackgroundEffect()
    #endif
}
