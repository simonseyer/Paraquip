//
//  ProfileSectionHeader.swift
//  Paraquip
//
//  Created by Simon Seyer on 16.06.22.
//

import SwiftUI

struct ProfileSectionHeader: View {
    
    let equipmentType: Equipment.EquipmentType
    
    init(equipmentType: Equipment.EquipmentType) {
        self.equipmentType = equipmentType
    }

    init(equipmentType: Int16) {
        self.equipmentType = .init(rawValue: equipmentType)!
    }

    var body: some View {
        HStack {
            equipmentType.iconImage
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.accentColor)
                .frame(width: 20, height: 20)
            Text(equipmentType.localizedName)
        }
    }
}

struct ProfileSectionHeader_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ProfileSectionHeader(equipmentType: .paraglider)
            ProfileSectionHeader(equipmentType: .harness)
            ProfileSectionHeader(equipmentType: .reserve)
        }.previewLayout(.sizeThatFits)
    }
}
