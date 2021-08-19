//
//  ManualView.swift
//  Paraquip
//
//  Created by Simon Seyer on 19.08.21.
//

import SwiftUI

struct ManualView: View {

    let manual: Data

    var dismiss: () -> Void
    var deleteManual: () -> Void

    var body: some View {
        PDFViewer(pdfData: manual)
            .navigationTitle("Manual")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done", action: dismiss)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        deleteManual()
                    }) {
                        Image(systemName: "trash")
                    }
                }
            }
    }
}

struct ManualView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ManualView(manual: Data(), dismiss: {}, deleteManual: {})
        }
    }
}
