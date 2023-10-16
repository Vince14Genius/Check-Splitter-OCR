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
    let imageSize: CGSize
    let shouldShowOCRText: Bool
    let isRotated: Bool
    let addResultToActiveItem: (OCRResult) -> Void
    let addPairToActiveItem: (String, Double) -> Void
    
    @State private var scale = 1.0
    
    private func animatePop() {
        scale = 1.2
        _ = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
            scale = 1.0
        }
    }
    
    var body: some View {
        OCRResultLabel(
            result: result,
            frameSize: frameSize,
            imageSize: imageSize,
            shouldShowOCRText: shouldShowOCRText,
            isRotated: isRotated,
            scale: scale
        )
        .animation(.bouncy, value: scale)
        .onTapGesture {
            addResultToActiveItem(result)
            animatePop()
        }
        .dropDestination(for: String.self) { droppedStrings, _ in
            if let price = Double(droppedStrings.first ?? "") {
                switch result.value {
                case .price(_):
                    return false
                case .name(let name):
                    addPairToActiveItem(name, price)
                    animatePop()
                    return true
                }
            } else if let name = droppedStrings.first {
                switch result.value {
                case .price(let price):
                    addPairToActiveItem(name, price)
                    animatePop()
                    return true
                case .name(_):
                    return false
                }
            } else {
                return false
            }
        }
        .environment(\.colorScheme, .light)
    }
}
