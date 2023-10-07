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
                .frame(width: 22)
            Text(equipmentType.pluralLocalizedName)
        }
    }
}

#Preview {
    VStack {
        ProfileSectionHeader(equipmentType: .paraglider)
        ProfileSectionHeader(equipmentType: .harness)
        ProfileSectionHeader(equipmentType: .reserve)
    }
}
