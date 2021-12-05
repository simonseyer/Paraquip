//
//  BrandRow.swift
//  Paraquip
//
//  Created by Simon Seyer on 08.05.21.
//

import SwiftUI

fileprivate extension Brand {
    var selectionName: String {
        switch self {
        case .none:
            return "None"
        case .custom:
            return "Custom"
        case .known(let name, _):
            return name
        }
    }
}

struct BrandRow: View {

    let brand: Brand

    var body: some View {
        HStack {
            if case .known(_, let logo) = brand {
                BrandIconView(image: UIImage(named: logo)!, area: 1500, alignment: .leading)
                    .frame(width: 70, height: 50, alignment: .center)
                    .padding(.trailing, 12)
            }
            Text(brand.selectionName)
        }
    }
}

struct BrandRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ForEach(Brand.allCases) { brand in
                BrandRow(brand: brand)
            }
        }
    }
}
