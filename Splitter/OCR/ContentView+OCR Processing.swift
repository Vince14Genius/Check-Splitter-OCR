//
//  OCRProcessor.swift
//  Splitter
//
//  Created by Vincent C. on 8/30/23.
//

import Vision
import Foundation
import RegexBuilder
import UIKit

struct OCRResult {
    enum ResultType {
        case price(value: Double)
        case name(text: String)
    }
    
    let value: ResultType
    let boundingBox: CGRect?
    
    private static let separatorPattern = try! Regex("[\(Currency.symbolsToExclude.joined())]")
    
    private static func pricesWithOmittedChars(recognizedText: VNRecognizedText) -> [Double] {
        recognizedText.string.split(separator: separatorPattern).compactMap {
            Double(String($0))
        }
    }
    
    private static func priceFromUSGroceryReceipt(recognizedText: VNRecognizedText) -> Double? {
        var text = recognizedText.string
        guard
            let last = text.last,
            let penultimate = text.suffix(2).first,
            last.isASCII, last.isUppercase, penultimate.isWhitespace
        else { return nil }
        text.removeLast(2)
        return Double(text)
    }
    
    init(_ recognizedText: VNRecognizedText) {
        if let price = Double(recognizedText.string) {
            value = .price(value: price)
        } else if let price = OCRResult.pricesWithOmittedChars(recognizedText: recognizedText).first {
            value = .price(value: price)
        } else if let price = OCRResult.priceFromUSGroceryReceipt(recognizedText: recognizedText) {
            value = .price(value: price)
        } else {
            value = .name(text: recognizedText.string)
        }
        
        let stringRange = recognizedText.string.startIndex ..< recognizedText.string.endIndex
        boundingBox = try? recognizedText.boundingBox(for: stringRange)?.boundingBox
    }
}

extension ReceiptStage {
    func runOCR(image: UIImage) {
        guard let cgImage = image.cgImage else {
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
        processOCRResults(recognizedTexts)
    }
}
