//
//  PDFViewer.swift
//  Paraquip
//
//  Created by Simon Seyer on 19.08.21.
//

import Foundation
import SwiftUI
import PDFKit

struct PDFViewer: UIViewControllerRepresentable {

    let pdfData: Data

    func makeUIViewController(context: UIViewControllerRepresentableContext<PDFViewer>) -> ViewController {
        let viewController = ViewController()
        viewController.pdfView.document = PDFDocument(data: pdfData)
        return viewController
    }

    func updateUIViewController(_ uiViewController: ViewController, context: Context) {

    }

    class ViewController: UIViewController {
        let pdfView = PDFView()

        override func loadView() {
            view = pdfView
            pdfView.autoScales = true
        }

        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            pdfView.minScaleFactor = pdfView.scaleFactorForSizeToFit
        }
    }
}
