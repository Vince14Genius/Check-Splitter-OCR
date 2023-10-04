//
//  OCRResultLabel.swift
//  Splitter
//
//  Created by Vincent C. on 9/2/23.
//

import SwiftUI
import Vision

struct OCRResultLabel: View {
    let result: OCRResult
    let frameSize: CGSize
    let imageState: OCRPhotoModel.ImageState
    let shouldShowOCRText: Bool
    let isRotated: Bool
    let scale: Double
    
    private func realImageSize(proxySize: CGSize, imageState: OCRPhotoModel.ImageState) -> CGSize {
        guard case let .success(image) = imageState else {
            return .zero
        }
        // handle rotation
        let imageWidth = isRotated ? image.size.height : image.size.width
        let imageHeight = isRotated ? image.size.width : image.size.height
        
        // width / height
        let imageDimensionRatio = imageWidth / imageHeight
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
    
    private var backgroundOpacity: Double {
        shouldShowOCRText ? 0.7 : 0.4
    }
    
    var body: some View {
        let themeColor: Color = switch result.value {
            case .name(_): .blue
            case .price(_): .green
        }
        let imageViewSize = realImageSize(
            proxySize: frameSize,
            imageState: imageState
        )
        let unnormalizedRect = VNImageRectForNormalizedRect(
            result.boundingBox ?? .zero,
            Int(imageViewSize.width),
            Int(imageViewSize.height)
        )
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .stroke(themeColor)
                .fill(Color(.systemBackground).opacity(backgroundOpacity))
                .frame(
                    width: unnormalizedRect.width,
                    height: unnormalizedRect.height
                )
                .shadow(color: themeColor.opacity(backgroundOpacity), radius: 4)
            Text({
                switch result.value {
                case .name(let text): text
                case .price(let value): value.formatted()
                }
            }())
            .rotationEffect(isRotated ? .degrees(-90) : .zero)
            .foregroundStyle(.primary)
            .fixedSize(horizontal: false, vertical: true) // SwiftUI text truncation bug workaround
            .opacity(shouldShowOCRText ? 1.0 : 0.1)
        }
        .animation(.easeInOut, value: shouldShowOCRText)
        .scaleEffect(scale)
        .draggable(result.value.draggableRepresentation) {
            let rawText = result.value.draggableRepresentation
            let price = Double(rawText)
            Text(price?.formatted() ?? rawText)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(price == nil ? .blue : .green, style: .init(lineWidth: 2))
                        .fill(Color(.systemBackground).opacity(backgroundOpacity))
                        .shadow(color: (price == nil ? Color.blue : Color.green).opacity(backgroundOpacity), radius: 4)
                }
        }
        .offset(
            x: unnormalizedRect.midX - imageViewSize.width / 2,
            y: -(unnormalizedRect.midY - imageViewSize.height / 2)
        )
    }
}

private extension OCRResult.ResultType {
    var draggableRepresentation: String {
        switch self {
        case .price(let value): String(value)
        case .name(let text): text
        }
    }
}
