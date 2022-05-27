//
//  PDFPreviewView.swift
//  Paraquip
//
//  Created by Simon Seyer on 26.05.22.
//

import Foundation
import SwiftUI
import PDFKit

struct PDFPreviewView: UIViewControllerRepresentable {

    let pdfData: Data

    func makeUIViewController(context: UIViewControllerRepresentableContext<PDFPreviewView>) -> ViewController {
        let viewController = ViewController()
        viewController.thumbnailView.pdfView?.document = PDFDocument(data: pdfData)
        return viewController
    }

    func updateUIViewController(_ uiViewController: ViewController, context: Context) {

    }

    class ViewController: UIViewController {

        private lazy var pdfView = PDFView()
        lazy var thumbnailView: PDFThumbnailView = {
            let view = PDFThumbnailView()
            view.pdfView = pdfView
            return view
        }()

        override func loadView() {
            view = thumbnailView
            thumbnailView.thumbnailSize = CGSize(width: 100, height: 100)
            thumbnailView.contentInset = UIEdgeInsets.zero
            thumbnailView.layoutMode = .vertical
            thumbnailView.backgroundColor = UIColor.clear
        }
    }
}
