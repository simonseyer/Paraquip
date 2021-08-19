//
//  BrandRow.swift
//  Paraquip
//
//  Created by Simon Seyer on 08.05.21.
//

import SwiftUI

struct BrandRow: View {

    let brand: Brand

    var body: some View {
        HStack {
            if let logo = brand.id {
                Image(logo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 40, alignment: .center)

            }
            Text(brand.name)
        }
    }
}

struct BrandRow_Previews: PreviewProvider {
    static var previews: some View {
        BrandRow(brand: Brand.allBrands.first!)
    }
}
