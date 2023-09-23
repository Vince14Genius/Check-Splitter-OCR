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
        VStack {
            switch viewModel.imageState {
            case .success(let uiImage):
                let isRotated = uiImage.imageOrientation == .right
                ScrollView([.horizontal, .vertical]) {
                    let frameWidthRaw = uiImage.size.width * imageScale
                    let frameHeightRaw = uiImage.size.height * imageScale
                    let frameWidth = isRotated ? frameHeightRaw : frameWidthRaw
                    let frameHeight = isRotated ? frameWidthRaw : frameHeightRaw
                    let frameSize = CGSizeMake(frameWidth, frameHeight)
                    ZStack {
                        ImportedImageView(imageState: viewModel.imageState)
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
            default:
                ImportedImageView(imageState: viewModel.imageState)
            }
        }
        .background(Color(.secondarySystemBackground))
        .overlay(alignment: .bottom) {
            VStack(spacing: 0) {
                if !ocrResults.isEmpty {
                    HStack(spacing: 0) {
                        Button {
                            isShowingOCRLabels.toggle()
                        } label: {
                            Image(systemName: isShowingOCRLabels ? "eye" : "eye.slash")
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                        }
                        Divider()
                        Button {
                            zoomScale = zoomScale.next()
                        } label: {
                            Label("\(zoomScale.rawValue)x", systemImage: "plus.magnifyingglass")
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                        }
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.regularMaterial)
                            .stroke(.primary.opacity(0.1))
                    )
                    .padding()
                }
                Divider()
                HStack {
                    if !ocrResults.isEmpty {
                        ImagePicker(selection: $viewModel.imageSelection)
                        Spacer()
                        Button("Next") {
                            
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(items.isEmpty)
                    } else {
                        Spacer()
                        ImagePicker(selection: $viewModel.imageSelection)
                        Spacer()
                    }
                }
                .padding()
                .background(.regularMaterial)
            }
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
