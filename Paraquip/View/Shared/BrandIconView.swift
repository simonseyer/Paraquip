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
            .shadow(color: Color(uiColor: .white), radius: 0.5, x: 0.5, y: 0.5)
            .cornerRadius(1)
    }
}

struct BrandIconView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            BrandIconView(image: UIImage(named: "phi")!, area: 3000, alignment: .center)
            BrandIconView(image: UIImage(named: "bgd")!, area: 3000, alignment: .center)
            BrandIconView(image: UIImage(named: "gin")!, area: 3000, alignment: .center)
            BrandIconView(image: UIImage(named: "advance")!, area: 3000, alignment: .center)
        }
    }
}
