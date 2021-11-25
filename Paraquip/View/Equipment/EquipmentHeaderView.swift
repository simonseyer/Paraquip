//
//  EquipmentHeaderView.swift
//  Paraquip
//
//  Created by Simon Seyer on 25.11.21.
//

import SwiftUI

struct EquipmentHeaderView<TagView: View>: View {

    let brandName: String
    let icon: UIImage?
    let showManualAction: () -> Void
    let tags: () -> TagView

    init(brandName: String,
         icon: UIImage?,
         showManualAction: @escaping () -> Void,
         @ViewBuilder tags: @escaping () -> TagView) {
        self.brandName = brandName
        self.icon = icon
        self.showManualAction = showManualAction
        self.tags = tags
    }

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                HStack {
                    Text("by \(brandName)")
                        .font(.headline)
                    Button(action: showManualAction) {
                        Image(systemName: "book.fill")
                    }
                }
                tags().padding([.top, .bottom], 10)
            }
            Spacer()
            if let icon = icon {
                let iconSize = icon.size
                let iconArea = iconSize.width * iconSize.height
                // Calcuate scale for the area of the image and
                // apply sqrt to get the scaling for width/height
                let scale = sqrt(3000 / iconArea)

                Image(uiImage: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: iconSize.width * scale,
                           maxHeight: iconSize.height * scale,
                           alignment: .trailing)
                    .frame(maxWidth: 120, maxHeight: 80, alignment: .trailing)
            }
        }
        .padding([.leading, .trailing])
    }
}

struct EquipmentHeaderView_Previews: PreviewProvider {

    static var previews: some View {

            ForEach(Brand.allCases) { brand in
                EquipmentHeaderView(
                    brandName: brand.name,
                    icon: UIImage(named: brand.id),
                    showManualAction: {}) {
                        HStack {
                            PillLabel("Harness")
                            PillLabel("Size M")
                        }
                    }.previewLayout(.sizeThatFits)
            }

    }

}
