//
//  WeightRangeView.swift
//  Paraquip
//
//  Created by Simon Seyer on 05.12.21.
//

import SwiftUI

extension ClosedRange {
    func clamp(_ value : Bound) -> Bound {
        return self.lowerBound > value ? self.lowerBound
            : self.upperBound < value ? self.upperBound
            : value
    }
}

struct WeightRangeView: View {

    let minWeight: Double
    let maxWeight: Double
    let weight: Double

    private let bufferRatio = 0.3
    private let circleSize: CGFloat = 10

    private var bufferCount: Double {
        minWeight == 0 ? 1 : 2
    }

    private var relativeValue: Double {
        let buffer = (bufferRatio * (maxWeight - minWeight)) / (1.0 - bufferCount * bufferRatio)
        let minWithBuffer = minWeight - (bufferCount - 1) * buffer
        let maxWithBuffer = maxWeight + buffer

        let relativeValue = (weight - minWithBuffer) / (maxWithBuffer - minWithBuffer)
        return (0.0...1.0).clamp(relativeValue)
    }

    private var dotColor: Color {
        if weight >= minWeight && weight <= maxWeight {
            return .white
        } else {
            return .red
        }
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 4) {
                ZStack(alignment: .leading) {
                    HStack(spacing: 0) {
                        if bufferCount > 1 {
                            Rectangle()
                                .frame(width: bufferRatio * geometry.size.width)
                                .foregroundStyle(.thickMaterial)
                                .cornerRadius(circleSize, corners: [.topLeft, .bottomLeft])
                        }
                        Rectangle()
                            .frame(width: (1.0 - bufferCount * bufferRatio) * geometry.size.width)
                            .foregroundStyle(.accent)
                            .cornerRadius(bufferCount > 1 ? 0 : circleSize, corners: [.topLeft, .bottomLeft])
                        Rectangle()
                            .frame(width: bufferRatio * geometry.size.width)
                            .cornerRadius(circleSize, corners: [.topRight, .bottomRight])
                            .foregroundStyle(.thickMaterial)

                    }
                    Circle()
                        .foregroundStyle(dotColor)
                        .frame(width: circleSize)
                        .padding(.leading, relativeValue * (geometry.size.width - 4 - circleSize) + 2)
                }

                HStack {
                    if bufferCount > 1 {
                        Text("\(Int(minWeight)) kg")
                    }
                    Spacer()
                    Text("\(Int(maxWeight)) kg")

                }
                .font(.footnote)
                .monospacedDigit()
                .padding([.leading, .trailing], bufferRatio * geometry.size.width)
                .foregroundStyle(.secondary)
            }
        }
        .frame(height: 34)
    }
}

// MARK: Preview

private let minWeight = 90.0
private let minWeightI = 0.0
private let maxWeight = 120.0
private let values: [Double] = [50, 90, 100, 110, 120, 130, 160]

#Preview {
    VStack(spacing: 20) {
        ForEach(values, id: \.hashValue) { value in
            WeightRangeView(minWeight: minWeight, maxWeight: maxWeight, weight: value)
        }
        ForEach(values, id: \.hashValue) { value in
            WeightRangeView(minWeight: minWeightI, maxWeight: maxWeight, weight: value)
        }
    }
    .padding()
}
