//
//  OCRProcessor.swift
//  OCRTestApp
//
//  Created by Vincent C. on 8/30/23.
//

import Vision
import Foundation

struct OCRResult {
    enum ResultType {
        case price(value: Decimal)
        case name(text: String)
    }
    
    let value: ResultType
    let boundingBox: CGRect?
    
    init(_ recognizedText: VNRecognizedText) {
        if let price = Decimal(string: recognizedText.string) {
            value = .price(value: price)
        } else {
            value = .name(text: recognizedText.string)
        }
        
        let stringRange = recognizedText.string.startIndex ..< recognizedText.string.endIndex
        boundingBox = try? recognizedText.boundingBox(for: stringRange)?.boundingBox
    }
}

extension ReceiptStage {
    func runOCR(imageState: OCRPhotoModel.ImageState) {
        guard case let .success(uiImage) = imageState else {
            print("Image does not exist.")
            return
        }
        
        guard let cgImage = uiImage.cgImage else {
            print("Unable to extract CGImage from imported image.")
            return
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        let request = VNRecognizeTextRequest(completionHandler: recognizeTextHandler)
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        do {
            try requestHandler.perform([request])
        } catch {
            print("Unable to perform the requests: \(error).")
        }
    }
    
    private func recognizeTextHandler(request: VNRequest, error: Error?) {
        guard let observations =
                request.results as? [VNRecognizedTextObservation] else {
            print("No text observations")
            return
        }
        let recognizedTexts = observations.compactMap { observation in
            if let candidate = observation.topCandidates(1).first {
                OCRResult(candidate)
            } else {
                nil
            }
        }
        
        // Process the recognized strings.
        processResults(recognizedTexts)
    }
}