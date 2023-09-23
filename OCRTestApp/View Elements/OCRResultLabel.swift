//
//  OCRResultLabel.swift
//  OCRTestApp
//
//  Created by Vincent C. on 9/2/23.
//

import SwiftUI
import Vision

struct OCRResultLabel: View {
    let result: OCRResult
    let proxySize: CGSize
    let imageState: OCRPhotoModel.ImageState
    let shouldShowOCRText: Bool
    
    private func realImageSize(proxySize: CGSize, imageState: OCRPhotoModel.ImageState) -> CGSize {
        guard case let .success(image) = imageState else {
            return .zero
        }
        // width / height
        let imageDimensionRatio = image.size.width / image.size.height
        let proxyDimensionRatio = proxySize.width / proxySize.height
        
        if imageDimensionRatio > proxyDimensionRatio {
            // aspect ratio fit = fills width
            return .init(
                width: proxySize.width,
                height: proxySize.width / imageDimensionRatio
            )
        } else {
            // aspect ratio fit = fills height
            return .init(
                width: proxySize.height * imageDimensionRatio,
                height: proxySize.height
            )
        }
    }
    
    var body: some View {
        let imageViewSize = realImageSize(
            proxySize: proxySize,
            imageState: imageState
        )
        let unnormalizedRect = VNImageRectForNormalizedRect(
            result.boundingBox ?? .zero,
            Int(imageViewSize.width),
            Int(imageViewSize.height)
        )
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill({
                    switch result.value {
                    case .name(_): Color.blue.opacity(0.5)
                    case .price(_): Color.green.opacity(0.5)
                    }
                }())
                .frame(
                    width: unnormalizedRect.width,
                    height: unnormalizedRect.height
                )
            Text({
                switch result.value {
                case .name(let text): text
                case .price(let value): value.formatted()
                }
            }())
            .foregroundColor(Color(.systemBackground))
            .shadow(radius: 4)
            .fixedSize(horizontal: false, vertical: true) // SwiftUI text truncation bug workaround
            .opacity(shouldShowOCRText ? 1.0 : 0.0)
        }
        .offset(
            x: unnormalizedRect.midX - imageViewSize.width / 2,
            y: -(unnormalizedRect.midY - imageViewSize.height / 2)
        )
    }
}
