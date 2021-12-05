//
//  BrandIconView.swift
//  Paraquip
//
//  Created by Simon Seyer on 05.12.21.
//

import SwiftUI

struct BrandIconView: View {

    let image: UIImage
    let area: CGFloat
    let alignment: Alignment

    var body: some View {
        let iconSize = image.size
        let iconArea = iconSize.width * iconSize.height
        // Calcuate scale for the area of the image and
        // apply sqrt to get the scaling for width/height
        let scale = sqrt(area / iconArea)

        SharpImageView(image: image)
            .frame(maxWidth: iconSize.width * scale,
                   maxHeight: iconSize.height * scale,
                   alignment: alignment)
    }
}

struct BrandIconView_Previews: PreviewProvider {
    static var previews: some View {
        BrandIconView(image: UIImage(named: "phi")!, area: 3000, alignment: .center)
            .previewLayout(.sizeThatFits)
        BrandIconView(image: UIImage(named: "bgd")!, area: 3000, alignment: .center)
            .previewLayout(.sizeThatFits)
    }
}
