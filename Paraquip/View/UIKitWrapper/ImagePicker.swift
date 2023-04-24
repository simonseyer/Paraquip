//
//  ImagePicker.swift
//  Paraquip
//
//  Created by Simon Seyer on 27.05.22.
//

import Foundation
import SwiftUI
import PhotosUI

@MainActor
struct ImagePicker: UIViewControllerRepresentable {

    let selectFile: @MainActor (URL) -> Void

    @Environment(\.dismiss) private var dismiss

    func makeCoordinator() -> Self.Coordinator {
        return Self.Coordinator(parent: self)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<Self>) -> PHPickerViewController {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = .images
        configuration.selectionLimit = 1

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: Self.UIViewControllerType, context: UIViewControllerRepresentableContext<Self>) {
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: ImagePicker

        init(parent: ImagePicker){
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let provider = results.first?.itemProvider else {
                return
            }

            provider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) {[parent] url, error in
                if let error {
                    // TODO: error handling
                    print("Can't load image \(error.localizedDescription)")
                } else if let url {
                    Task { @MainActor in
                        parent.selectFile(url)
                    }
                }
            }
        }
    }
}

