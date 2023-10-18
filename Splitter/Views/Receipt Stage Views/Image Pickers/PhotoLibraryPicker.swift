//
//  PhotoLibraryPicker.swift
//  Splitter
//
//  Created by Vincent C. on 8/30/23.
//

import SwiftUI
import PhotosUI
import CoreTransferable

struct PhotoLibraryPicker: View {
    @Binding var imageItem: ImagePickerItem
    
    @State private var selection: PhotosPickerItem?
    
    var body: some View {
        Group {
            if case .success(_) = imageItem {
                PhotosPicker(selection: $selection,
                             matching: .images,
                             photoLibrary: .shared()) {
                    Label("Repick Image", systemImage: "photo.on.rectangle")
                }
                .buttonStyle(.bordered)
            } else {
                PhotosPicker(selection: $selection,
                             matching: .images,
                             photoLibrary: .shared()) {
                    Label("Photo Library", systemImage: "photo.on.rectangle")
                }
            }
        }
        .onChange(of: selection) { _, newValue in
            if let newValue {
                let progress = loadTransferable(from: newValue)
                imageItem = .loading(progress)
            } else {
                imageItem = .empty
            }
        }
    }
    
    private func loadTransferable(from imageSelection: PhotosPickerItem) -> Progress {
        return imageSelection.loadTransferable(type: ImportedImage.self) { result in
            DispatchQueue.main.async {
                guard imageSelection == selection else {
                    print("Failed to get the selected item.")
                    return
                }
                switch result {
                case .success(let importedImage?):
                    self.imageItem = .success(image: importedImage.image)
                case .success(nil):
                    self.imageItem = .empty
                case .failure(let error):
                    self.imageItem = .failure(error)
                }
            }
        }
    }
}

private enum TransferError: Error {
    case importFailed
}

private struct ImportedImage: Transferable {
    let image: UIImage
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
            guard let uiImage = UIImage(data: data) else {
                throw TransferError.importFailed
            }
            return ImportedImage(image: uiImage)
        }
    }
}
