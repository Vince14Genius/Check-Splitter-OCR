//
//  OCRResultsFrame.swift
//  Splitter
//
//  Created by Vincent C. on 9/23/23.
//

import SwiftUI

struct OCRResultsFrame: View {
    enum ZoomScale: Double, CaseIterable {
        case zoom0_5x = 0.5
        case zoom1x = 1.0
        case zoom2x = 2.0
        
        func next() -> ZoomScale {
            let allCases = ZoomScale.allCases
            let currentIndex = allCases.firstIndex(of: self)!
            let nextIndex = (currentIndex + 1) % allCases.count
            return allCases[nextIndex]
        }
    }
    
    let uiImage: UIImage
    let ocrResults: [OCRResult]
    let imageState: OCRPhotoModel.ImageState
    let imageScale: Double
    let shouldShowOCRText: Bool
    @Binding var floatingBarState: FloatingBarState
    
    @State private var isShowingPriceZeroAlert = false
    
    private func addResultToActiveItem(_ result: OCRResult) {
        var itemToEdit = Item.Initiation()
        if case .focused(let item) = floatingBarState {
            itemToEdit = item
        }
        switch result.value {
        case .name(let text):
            itemToEdit.name = text
        case .price(let value):
            do {
                try itemToEdit.setPrice(to: value)
            } catch {
                if case Item.AssignmentError.itemPriceZero = error {
                    isShowingPriceZeroAlert = true
                    return
                }
            }
        }
        floatingBarState = .focused(item: itemToEdit)
    }
    
    var body: some View {
        let isRotated = uiImage.imageOrientation == .right
        let frameWidthRaw = uiImage.size.width * imageScale
        let frameHeightRaw = uiImage.size.height * imageScale
        let frameSize = CGSizeMake(
            isRotated ? frameHeightRaw : frameWidthRaw,
            isRotated ? frameWidthRaw : frameHeightRaw
        )
        ZStack {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
            ZStack {
                ForEach(ocrResults.indices, id: \.self) { i in
                    let result = ocrResults[i]
                    OCRResultButton(
                        result: result,
                        frameSize: frameSize,
                        imageState: imageState,
                        shouldShowOCRText: shouldShowOCRText,
                        isRotated: isRotated,
                        action: addResultToActiveItem(_:)
                    )
                }
            }
            .rotationEffect(isRotated ? .degrees(90) : .zero)
        }
        .frame(width: frameWidthRaw, height: frameHeightRaw)
        .alert("Invalid price: 0 is not allowed", isPresented: $isShowingPriceZeroAlert) {}
    }
}

#Preview {
    ReceiptStage(items: [
        .init(name: "hello", price: 9.99),
        .init(name: "たこわさ", price: 7.99)
    ])
}
