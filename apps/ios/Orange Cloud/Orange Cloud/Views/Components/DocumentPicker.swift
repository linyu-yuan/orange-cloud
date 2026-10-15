//
//  DocumentPicker.swift
//  Orange Cloud
//
//  UIKit UIDocumentPickerViewController wrapper (asCopy: true).
//  Used instead of SwiftUI .fileImporter, which in nested sheets / Form sections
//  could present the Files UI with every item disabled.
//

import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct DocumentPicker: UIViewControllerRepresentable {
    var contentTypes: [UTType] = [.item, .data, .content]
    var allowsMultipleSelection: Bool = false
    var onPick: ([URL]) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(onPick: onPick) }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: contentTypes, asCopy: true)
        picker.allowsMultipleSelection = allowsMultipleSelection
        picker.shouldShowFileExtensions = true
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        context.coordinator.onPick = onPick
    }

    final class Coordinator: NSObject, UIDocumentPickerDelegate {
        var onPick: ([URL]) -> Void
        init(onPick: @escaping ([URL]) -> Void) { self.onPick = onPick }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            onPick(urls)
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {}
    }
}

extension View {
    /// Drop-in replacement for `.fileImporter`: presents a UIKit document picker in a sheet.
    func documentPicker(
        isPresented: Binding<Bool>,
        allowsMultipleSelection: Bool = false,
        onPick: @escaping ([URL]) -> Void
    ) -> some View {
        sheet(isPresented: isPresented) {
            DocumentPicker(allowsMultipleSelection: allowsMultipleSelection) { urls in
                isPresented.wrappedValue = false
                // Let the sheet dismiss before mutating state that may re-render the presenter.
                DispatchQueue.main.async { onPick(urls) }
            }
            .ignoresSafeArea()
        }
    }
}
