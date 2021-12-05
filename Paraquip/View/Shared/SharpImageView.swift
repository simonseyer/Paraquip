//
//  SharpImageView.swift
//  Paraquip
//
//  Created by Simon Seyer on 05.12.21.
//

import SwiftUI

/// Wraps the UIKit UIImageView in order to render SVGs without blur
struct SharpImageView: UIViewRepresentable {
    var image: UIImage
    var contentMode: UIView.ContentMode = .scaleAspectFit

    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.setContentCompressionResistancePriority(.fittingSizeLevel,
                                                          for: .vertical)
        imageView.setContentCompressionResistancePriority(.fittingSizeLevel,
                                                          for: .horizontal)
        return imageView
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {
        uiView.contentMode = contentMode
        uiView.image = image
    }
}
struct SharpImageView_Previews: PreviewProvider {
    static var previews: some View {
        SharpImageView(image: UIImage(named: "bgd")!)
            .frame(width: 200, height: 200, alignment: .center)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
