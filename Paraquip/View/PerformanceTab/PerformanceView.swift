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
    // Double empty space important to avoid glitchy animation
    @State private var navigationTitle: String = " "

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedProfile) {
                ForEach(profiles) { profile in
                    NavigationLink(value: profile) {
                        Label(profile.profileName,
                              systemImage: profile.profileIcon.systemName)

                    }
                }
                if let selectedProfile {
                    DeletionObserverView(object: selectedProfile) {
                        self.selectedProfile = nil
                    }
                }
            }
            .navigationTitle("Performance")
        } detail: {
            HStack {
                if let selectedProfile {
                    ProfileWeightView(profile: selectedProfile)
                } else {
                    ContentUnavailableView("Select an equipment set",
                                           systemImage: "tray.full.fill")
                }
            }
            .navigationTitle(navigationTitle)
        }
        .onChange(of: selectedProfile, initial: true) {
            navigationTitle = selectedProfile?.profileName ?? " "
        }
    }
}

#Preview {
    PerformanceView()
        .environment(\.managedObjectContext, .preview)
}
