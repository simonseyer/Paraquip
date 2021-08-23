//
//  EquipmentView.swift
//  Paraquip
//
//  Created by Simon Seyer on 18.04.21.
//

import SwiftUI

struct EquipmentView: View {

    @ObservedObject var viewModel: EquipmentViewModel

    @State private var showingEditEquipment = false
    @State private var showingLogCheck = false
    @State private var editMode: EditMode = .inactive
    @State private var showingManual = false

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    HStack {
                        Text("by \(viewModel.equipment.brand.name)")
                            .font(.headline)
                        Button(action: {
                            showingManual.toggle()
                        }) {
                            Image(systemName: "book.fill")
                        }
                    }
                    HStack {
                        PillLabel(LocalizedStringKey(viewModel.equipment.localizedType))
                        if let paraglider = viewModel.equipment as? Paraglider {
                            PillLabel("Size \(paraglider.size.rawValue)")
                        }
                    }
                    .padding([.top, .bottom], 10)
                }
                Spacer()
                if let icon = viewModel.equipment.icon {
                    icon
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                }
            }
            .padding([.leading, .trailing])

            List {
                if viewModel.equipment.timeline.isEmpty {
                    Text("No check logged")
                        .foregroundColor(Color(UIColor.systemGray))
                } else {
                    ForEach(viewModel.equipment.timeline) { entry in
                        TimelineViewCell(timelineEntry: entry) {
                            showingLogCheck = true
                        }
                        .deleteDisabled(!entry.isCheck)
                    }
                    .onDelete(perform: { indexSet in
                        let offsets = viewModel.equipment.timeline.checkIndexSet(from: indexSet)
                        viewModel.removeChecks(atOffsets: offsets)
                        if viewModel.equipment.checkLog.isEmpty {
                            withAnimation {
                                editMode = .inactive
                            }
                        }
                    })
                }
            }
            .listStyle(InsetGroupedListStyle())
            .environment(\.editMode, $editMode)
            .toolbar {
                Button("Edit") {
                    showingEditEquipment = true
                }
            }
            .navigationTitle(viewModel.equipment.name)
            .sheet(isPresented: $showingEditEquipment) {
                NavigationView {
                    EditEquipmentView(viewModel: viewModel.editEquipmentViewModel()) {
                        showingEditEquipment = false
                    }
                }
            }
            .sheet(isPresented: $showingLogCheck) {
                LogCheckView() { date in
                    if let checkDate = date {
                        viewModel.logCheck(at: checkDate)
                    }
                    showingLogCheck = false
                }
            }
            .sheet(isPresented: $showingManual) {
                if let manual = viewModel.loadManual() {
                    NavigationView {
                        ManualView(manual: manual, dismiss: {
                            showingManual = false
                        }, deleteManual: {
                            viewModel.deleteManual()
                            showingManual = false
                        })
                    }
                } else {
                    DocumentPicker() { url in
                        viewModel.attachManual(at: url)
                    }
                }
            }
        }
    }
}

extension Array where Element == TimelineEntry {
    /// Returns an index set mapped back to the check log
    func checkIndexSet(from indexSet: IndexSet) -> IndexSet {
        guard let firstIndex = indexSet.first else {
            return indexSet
        }
        var newIndexSet = indexSet
        newIndexSet.shift(startingAt: firstIndex, by: -1)
        return newIndexSet
    }
}

struct EquipmentView_Previews: PreviewProvider {

    private static let profile = Profile.fake()
    private static let store = FakeProfileStore(profile: profile)

    static var previews: some View {
        Group {
            NavigationView {
                EquipmentView(viewModel: EquipmentViewModel(store: store, equipment: profile.equipment[0]))
            }

            NavigationView {
                EquipmentView(viewModel: EquipmentViewModel(store: store, equipment: profile.equipment[1]))
            }
        }
        .environment(\.locale, .init(identifier: "de"))
    }
}
