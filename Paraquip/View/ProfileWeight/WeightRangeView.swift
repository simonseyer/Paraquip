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

    let minWeight: Measurement<UnitMass>
    let maxWeight: Measurement<UnitMass>
    let weight: Measurement<UnitMass>

    private let bufferRatio = 0.3
    private let circleSize: CGFloat = 8

    private var bufferCount: Double {
        minWeight.value == 0 ? 1 : 2
    }

    private var relativeValue: Double {
        let min = minWeight.converted(to: .baseUnit()).value
        let max = maxWeight.converted(to: .baseUnit()).value
        let value = weight.converted(to: .baseUnit()).value

        let buffer = (bufferRatio * (max - min)) / (1.0 - bufferCount * bufferRatio)
        let minWithBuffer = min - (bufferCount - 1) * buffer
        let maxWithBuffer = max + buffer

        let relativeValue = (value - minWithBuffer) / (maxWithBuffer - minWithBuffer)
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
                                .foregroundColor(Color(UIColor.systemGray5))
                                .cornerRadius(circleSize, corners: [.topLeft, .bottomLeft])
                        }
                        Rectangle()
                            .frame(width: (1.0 - bufferCount * bufferRatio) * geometry.size.width)
                            .foregroundColor(.accentColor)
                            .cornerRadius(bufferCount > 1 ? 0 : circleSize, corners: [.topLeft, .bottomLeft])
                        Rectangle()
                            .frame(width: bufferRatio * geometry.size.width)
                            .cornerRadius(circleSize, corners: [.topRight, .bottomRight])
                            .foregroundColor(Color(UIColor.systemGray5))

                    }
                    Circle()
                        .foregroundColor(dotColor)
                        .frame(width: circleSize)
                        .padding(.leading, relativeValue * (geometry.size.width - 4 - circleSize) + 2)
                }

                HStack {
                    if bufferCount > 1 {
                        Text(minWeight, format: .measurement(width: .abbreviated))
                    }
                    Spacer()
                    Text(maxWeight, format: .measurement(width: .abbreviated))

                }
                .font(.footnote)
                .monospacedDigit()
                .padding([.leading, .trailing], bufferRatio * geometry.size.width)
                .foregroundColor(.secondary)
            }
        }
        .frame(height: 32)
    }
}

struct WeightRangeView_Previews: PreviewProvider {

    static let minWeight = Measurement<UnitMass>(value: 90, unit: .kilograms)
    static let minWeightI = Measurement<UnitMass>(value: 0, unit: .kilograms)
    static let maxWeight = Measurement<UnitMass>(value: 120, unit: .kilograms)
    static let values: [Measurement<UnitMass>] = [
        .init(value: 50, unit: .kilograms),
        .init(value: 90, unit: .kilograms),
        .init(value: 100, unit: .kilograms),
        .init(value: 110, unit: .kilograms),
        .init(value: 120, unit: .kilograms),
        .init(value: 130, unit: .kilograms),
        .init(value: 160, unit: .kilograms)
    ]

    static var previews: some View {
        ForEach(values, id: \.value) { value in
            WeightRangeView(minWeight: minWeight, maxWeight: maxWeight, weight: value)
                .previewLayout(.sizeThatFits)
        }
        ForEach(values, id: \.value) { value in
            WeightRangeView(minWeight: minWeightI, maxWeight: maxWeight, weight: value)
                .previewLayout(.sizeThatFits)
        }
    }
}
