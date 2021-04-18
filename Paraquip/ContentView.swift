//
//  ContentView.swift
//  Paraquip
//
//  Created by Simon Seyer on 09.04.21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            ProfileView()
        }
        .environmentObject(ProfileStore(profile: Profile.fake()))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
