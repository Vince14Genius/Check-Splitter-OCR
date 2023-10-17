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
        case zoom5x = 5.0
    }
    
    let uiImage: UIImage
    let ocrResults: [OCRResult]
    let imageScale: Double
    let shouldShowOCRText: Bool
    @Binding var totalCost: Double?
    let addResultToActiveItem: (OCRResult) -> Void
    let addPairToActiveItem: (String, Double) -> Void
    
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
                        imageSize: uiImage.size,
                        shouldShowOCRText: shouldShowOCRText,
                        isRotated: isRotated,
                        totalCost: $totalCost,
                        addResultToActiveItem: addResultToActiveItem,
                        addPairToActiveItem: addPairToActiveItem
                    )
                }
            }
            .rotationEffect(isRotated ? .degrees(90) : .zero)
        }
        .frame(width: frameWidthRaw, height: frameHeightRaw)
    }
}

#Preview {
    StageSwitcherView(flowState: .sampleData)
}
