//
//  EditSetView.swift
//  EditSetView
//
//  Created by Simon Seyer on 26.08.21.
//

import SwiftUI

struct EditSetView: View {

    @ObservedObject var viewModel: EditSetViewModel
    @Environment(\.dismiss) private var dismiss

    @ViewBuilder
    var attributionFooter: some View {
        Text("Icons by Font Awesome used without modification. See [license](https://fontawesome.com/license).")
    }

    var body: some View {
        Form {
            Section(footer: attributionFooter) {
                TextField("Name", text: $viewModel.profile.name)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(Profile.Icon.allCases) { icon in
                            IconSelectionView(
                                icon: icon,
                                isSelected: icon == viewModel.profile.icon)
                                .onTapGesture {
                                    viewModel.profile.icon = icon
                                }
                        }
                    }
                }
            }

            Section("Equipment") {
                ForEach(viewModel.equipment, id: \.id) { equipment in
                    Button(action: {
                        viewModel.toggle(equipment: equipment)
                    }) {
                        HStack {
                            Text("\(equipment.brand.name) \(equipment.name)")
                            Spacer()
                            if viewModel.isSelected(equipment: equipment) {
                                Image(systemName: "checkmark")
                                    .font(.system(.body).weight(.medium))
                                    .foregroundColor(.accentColor)
                            }}
                    }
                    .foregroundColor(.primary)
                }
            }
        }
        .navigationTitle(viewModel.profile.name.isEmpty ? "New Set" : viewModel.profile.name)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    viewModel.save()
                    dismiss()
                }
            }
        }
    }
}

struct EdiSetView_Previews: PreviewProvider {

    static let appStore = FakeAppStore()

    static var previews: some View {
        NavigationView {
            EditSetView(viewModel: EditSetViewModel(appStore: appStore, profile: appStore.profiles.value.first!))
        }
    }
}

struct IconSelectionView: View {

    let icon: Profile.Icon
    let isSelected: Bool

    var body: some View {
        Image(icon.rawValue)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .padding(12)
            .frame(width: 50, height: 50)
            .background(
                isSelected ? Color.accentColor :
                    Color(UIColor.systemGray5)
            )
            .cornerRadius(10)
            .padding(.trailing, 10)

    }
}
