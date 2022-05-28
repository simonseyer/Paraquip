//
//  ManualView.swift
//  Paraquip
//
//  Created by Simon Seyer on 19.08.21.
//

import SwiftUI

struct ManualView: View {

    let manual: Data

    @Environment(\.dismiss) private var dismiss
    var deleteManual: () -> Void

    var body: some View {
        PDFViewer(pdfData: manual)
            .navigationTitle("Manual")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .destructiveAction) {
                    Button("Delete", action: {
                        deleteManual()
                        dismiss()
                    })
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
    }
}

struct ManualView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ManualView(manual: Data(), deleteManual: {})
        }
        .environment(\.locale, .init(identifier: "de"))
    }
}
