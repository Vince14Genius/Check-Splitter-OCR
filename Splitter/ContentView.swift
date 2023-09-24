//
//  ContentView.swift
//  OCRTestApp
//
//  Created by Vincent C. on 8/27/23.
//

import SwiftUI
import Vision
import Foundation

struct ContentView: View {
    @State private var viewModel = OCRPhotoModel()
    @State private var ocrResults: [OCRResult] = []
    
    @State private var isShowingOCRLabels = true
    @State private var floatingBarState: FloatingBarState = .minimized
    
    @State var items = [Item]()
    @State var totalCost: Decimal?
    @AppStorage("currency", store: .standard) var currency: Currency = .usd
    
    @Environment(\.displayScale) private var displayScale
    @State private var zoomScale: OCRResultsFrame.ZoomScale = .zoom1x
    
    private var imageScale: Double {
        1 / displayScale * zoomScale.rawValue
    }
    
    private var isNextButtonEnabled: Bool {
        !items.isEmpty && totalCost != nil
    }
    
    var body: some View {
        ZStack {
            switch viewModel.imageState {
            case .success(let uiImage):
                ScrollView([.horizontal, .vertical]) {
                    OCRResultsFrame(
                        uiImage: uiImage,
                        ocrResults: ocrResults,
                        imageState: viewModel.imageState,
                        imageScale: imageScale,
                        shouldShowOCRText: isShowingOCRLabels,
                        floatingBarState: $floatingBarState
                    )
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
                isNextButtonEnabled: isNextButtonEnabled,
                isImageToolbarEnabled: !ocrResults.isEmpty,
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
            VStack {
                TotalCostField(value: $totalCost, currency: currency)
                FloatingItemsList(items: $items, state: $floatingBarState, currency: currency)
            }
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
