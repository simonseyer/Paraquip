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
    let tags: () -> TagView

    init(brandName: String,
         icon: UIImage?,
         @ViewBuilder tags: @escaping () -> TagView) {
        self.brandName = brandName
        self.icon = icon
        self.tags = tags
    }

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                HStack {
                    Text("by \(brandName)")
                        .font(.headline)
                }
                tags().padding([.top, .bottom], 10)
            }
            Spacer()
            if let icon = icon {
                BrandIconView(image: icon, area: 4000, alignment: .trailing)
                    .frame(maxWidth: 130, maxHeight: 80, alignment: .trailing)
            }
        }
        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
    }
}

struct EquipmentHeaderView_Previews: PreviewProvider {

    static var previews: some View {
        ForEach(Equipment.brandSuggestions, id: \.hashValue) { brand in
                EquipmentHeaderView(
                    brandName: brand,
                    icon: UIImage(named: brand.slugified())) {
                        HStack {
                            PillLabel("Harness")
                            PillLabel("Size M")
                        }
                    }.previewLayout(.sizeThatFits)
            }

    }

}
