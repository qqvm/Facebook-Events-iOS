//
//  FilePicker.swift
//  fbevents
//
//  Created by User on 18.07.2020.
//  Copyright © 2020 nonced. All rights reserved.
//

import SwiftUI
import MobileCoreServices


struct FilePicker: UIViewControllerRepresentable {

    var callback: ([URL]) -> ()

    init(callback: @escaping ([URL]) -> ()) {
        self.callback = callback
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: UIViewControllerRepresentableContext<FilePicker>) {
        // nothing to do here
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let controller = UIDocumentPickerViewController(documentTypes: [kUTTypeItem as String], in: UIDocumentPickerMode.import)
        controller.allowsMultipleSelection = false
        controller.delegate = context.coordinator
        return controller
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: FilePicker
        init(_ pickerController: FilePicker) {
            self.parent = pickerController
        }
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.callback(urls)
        }
    }
}
