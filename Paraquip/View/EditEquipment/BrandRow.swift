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
                Image(logo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 40, alignment: .center)

            }
            Text(brand.selectionName)
        }
    }
}

struct BrandRow_Previews: PreviewProvider {
    static var previews: some View {
        BrandRow(brand: Brand.allCases.last!)
    }
}
