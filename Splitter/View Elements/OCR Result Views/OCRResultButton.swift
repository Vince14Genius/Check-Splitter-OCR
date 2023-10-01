//
//  OCRResultButton.swift
//  Splitter
//
//  Created by Vincent C. on 9/3/23.
//

import SwiftUI
import Vision

struct OCRResultButton: View {
    let result: OCRResult
    let frameSize: CGSize
    let imageState: OCRPhotoModel.ImageState
    let shouldShowOCRText: Bool
    let isRotated: Bool
    let action: (OCRResult) -> Void
    
    @State private var scale = 1.0
    
    var body: some View {
        OCRResultLabel(
            result: result,
            frameSize: frameSize,
            imageState: imageState,
            shouldShowOCRText: shouldShowOCRText,
            isRotated: isRotated,
            scale: scale
        )
        .animation(.bouncy, value: scale)
        .onTapGesture {
            scale = 1.2
            action(result)
            _ = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
                scale = 1.0
            }
        }
        .environment(\.colorScheme, .light)
    }
}

