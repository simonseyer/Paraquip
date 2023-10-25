//
//  Stripes.swift
//  Paraquip
//
//  Created by Simon Seyer on 13.07.23.
//

import Foundation
import CoreImage.CIFilterBuiltins
import SwiftUI

extension CGImage {
    fileprivate static func generateStripePattern(
        colors: (UIColor, UIColor) = (.clear, .black),
        width: CGFloat = 4,
        ratio: CGFloat = 0.8
    ) -> CGImage {
        let context = CIContext()
        let stripes = CIFilter.stripesGenerator()
        stripes.color0 = CIColor(color: colors.0)
        stripes.color1 = CIColor(color: colors.1)
        stripes.sharpness = 2
        stripes.width = Float(width * ratio)
        stripes.center = CGPoint(x: CGFloat(stripes.width), y: 0)
        let size = CGSize(width: width, height: 1)

        let stripesImage = stripes.outputImage!
        return context.createCGImage(stripesImage, from: CGRect(origin: .zero, size: size))!
    }
}

extension Shape {
    func stripes(color: UIColor = .black, angle: Double = 45) -> some View {
        let stripePattern = CGImage.generateStripePattern(colors: (.clear, color))
        return Rectangle()
            .fill(.clear)
            .background(
                Rectangle()
                    .padding(100)
                    .background(
                        Rectangle()
                            .fill(ImagePaint(image: Image(decorative: stripePattern, scale: 3.0)))
                            .rotationEffect(.degrees(angle))
                            .scaleEffect(3)
                    )

            )
            .clipShape(self)
    }
}
