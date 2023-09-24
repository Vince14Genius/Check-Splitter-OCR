//
//  ContentView.swift
//  OCRTestApp
//
//  Created by Vincent C. on 8/27/23.
//

import SwiftUI
import PhotosUI
import Vision
import Foundation

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

struct ContentView: View {
    @State private var viewModel = OCRPhotoModel()
    @State private var ocrResults: [OCRResult] = []
    
    @State private var isShowingOCRLabels = true
    @State private var floatingBarState: FloatingBarState = .minimized
    
    @State var items = [Item]()
    @AppStorage("currency", store: .standard) var currency: Currency = .usd
    
    @Environment(\.displayScale) private var displayScale
    @State private var zoomScale: ZoomScale = .zoom1x
    
    private var imageScale: Double {
        1 / displayScale * zoomScale.rawValue
    }
    
    private func addResultToActiveItem(_ result: OCRResult) {
        var itemToEdit = Item.Initiation()
        if case .focused(let item) = floatingBarState {
            itemToEdit = item
        }
        switch result.value {
        case .name(let text):
            itemToEdit.name = text
        case .price(let value):
            itemToEdit.price = value
        }
        floatingBarState = .focused(item: itemToEdit)
    }
    
    var body: some View {
        ZStack {
            switch viewModel.imageState {
            case .success(let uiImage):
                let isRotated = uiImage.imageOrientation == .right
                ScrollView([.horizontal, .vertical]) {
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
                                    imageState: viewModel.imageState,
                                    shouldShowOCRText: isShowingOCRLabels,
                                    isRotated: isRotated,
                                    action: addResultToActiveItem(_:)
                                )
                            }
                        }
                        .rotationEffect(isRotated ? .degrees(90) : .zero)
                    }
                    .frame(width: frameWidthRaw, height: frameHeightRaw)
                }
                if ocrResults.isEmpty {
                    Text("No text detected from image.")
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.regularMaterial)
                        )
                }
            case .loading:
                Centered {
                    ProgressView()
                }
            case .empty:
                Centered {
                    VStack {
                        Image(systemName: "text.viewfinder")
                            .font(.title)
                            .padding(.bottom)
                        Text("Scan a receipt from your Photo Library")
                            .font(.headline)
                        Text("Or enter items manually")
                    }
                }
            case .failure:
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
        }
        .background(Color(.secondarySystemBackground))
        .overlay(alignment: .bottom) {
            OCRBottomBar(
                items: items,
                ocrResults: ocrResults,
                isShowingOCRLabels: $isShowingOCRLabels,
                zoomScale: $zoomScale,
                viewModel: $viewModel
            )
        }
        .overlay(alignment: .topLeading) {
            CurrencyPicker(currency: $currency)
                .padding()
        }
        .overlay(alignment: .topTrailing) {
            FloatingItemsList(items: $items, state: $floatingBarState, currency: currency)
                .padding()
        }
        .onChange(of: viewModel.imageSelection) {
            ocrResults = []
            floatingBarState = .minimized
        }
        .onChange(of: viewModel.imageState) {
            if case .success(_) = viewModel.imageState {
                runOCR(imageState: viewModel.imageState)
            }
        }
        .animation(.easeInOut, value: floatingBarState)
        .animation(.easeInOut, value: zoomScale)
    }
    
    func processResults(_ results: [OCRResult]) {
        ocrResults = results
    }
}

#Preview {
    ContentView(items: [
        .init(name: "hello", price: 9.99),
        .init(name: "たこわさ", price: 7.99)
    ])
}
