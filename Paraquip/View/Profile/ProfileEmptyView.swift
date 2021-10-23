//
//  ProfileEmptyView.swift
//  Paraquip
//
//  Created by Simon Seyer on 17.10.21.
//

import SwiftUI

struct ProfileEmptyView: View {
    var body: some View {
        VStack {
            Image("icon")
                .frame(maxWidth: 120)
            Text("profile_empty_text")
                .font(.title3)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 250)
                .padding()
        }
    }
}

struct ProfileEmptyView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileEmptyView()
    }
}
