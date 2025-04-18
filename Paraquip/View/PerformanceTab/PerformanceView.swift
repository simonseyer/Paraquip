//
//  PerformanceView.swift
//  Paraquip
//
//  Created by Simon Seyer on 22.09.23.
//

import SwiftUI

struct PerformanceView: View {

    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)])
    private var profiles: FetchedResults<Profile>

    @State private var selectedProfile: Profile?

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedProfile) {
                ForEach(profiles) { profile in
                    NavigationLink(value: profile) {
                        Label(profile.profileName,
                              systemImage: profile.profileIcon.systemName)

                    }
                }
            }
            .navigationTitle("Performance")
            .onReceive(profiles.publisher) { _ in
                if let selected = selectedProfile, !profiles.contains(selected) {
                    selectedProfile = nil
                }
            }
        } detail: {
            HStack {
                if let selectedProfile {
                    ProfileWeightView(profile: selectedProfile)
                } else {
                    ContentUnavailableView("Select an equipment set",
                                           systemImage: "tray.full.fill")
                }
            }
        }
    }
}

#Preview {
    PerformanceView()
        .environment(\.managedObjectContext, .preview)
}
