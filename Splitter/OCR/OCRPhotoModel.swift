//
//  OCRPhotoModel.swift
//  OCRTestApp
//
//  Created by Vincent C. on 8/30/23.
//

import SwiftUI
import PhotosUI
import CoreTransferable

@Observable class OCRPhotoModel {
    
    // MARK: - Imported Image
    
    enum ImageState: Equatable {
        case empty
        case loading(Progress)
        case success(UIImage)
        case failure(Error)
        
        static func == (lhs: OCRPhotoModel.ImageState, rhs: OCRPhotoModel.ImageState) -> Bool {
            switch lhs {
            case .empty:
                switch rhs {
                case .empty: true
                default: false
                }
            case .loading(_):
                switch rhs {
                case .loading(_): true
                default: false
                }
            case .success(_):
                switch rhs {
                case .success(_): true
                default: false
                }
            case .failure(_):
                switch rhs {
                case .failure(_): true
                default: false
                }
            }
        }
        
    }
    
    enum TransferError: Error {
        case importFailed
    }
    
    struct ImportedImage: Transferable {
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
    
    private(set) var imageState: ImageState = .empty
    
    var imageSelection: PhotosPickerItem? = nil {
        didSet {
            if let imageSelection {
                let progress = loadTransferable(from: imageSelection)
                imageState = .loading(progress)
            } else {
                imageState = .empty
            }
        }
    }
    
    var isOCRAvailable: Bool {
        switch imageState {
        case .success(_): true
        default: false
        }
    }
    
    // MARK: - Private Methods
    
    private func loadTransferable(from imageSelection: PhotosPickerItem) -> Progress {
        return imageSelection.loadTransferable(type: ImportedImage.self) { result in
            DispatchQueue.main.async {
                guard imageSelection == self.imageSelection else {
                    print("Failed to get the selected item.")
                    return
                }
                switch result {
                case .success(let importedImage?):
                    self.imageState = .success(importedImage.image)
                case .success(nil):
                    self.imageState = .empty
                case .failure(let error):
                    self.imageState = .failure(error)
                }
            }
        }
    }
}
