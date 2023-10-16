//
//  ReceiptStage.swift
//  Splitter
//
//  Created by Vincent C. on 8/27/23.
//

import SwiftUI
import Vision
import Foundation

struct ReceiptStage: View {
    @Binding var stage: Stage
    @Binding var path: [InfoEntryStage]
    
    @State private var imagePickerItem: ImagePickerItem = .empty
    @State private var ocrResults: [OCRResult] = []
    
    @State private var isShowingOCRLabels = true
    @State private var floatingBarState: FloatingBarState = .minimized
    
    @State private var isShowingPriceZeroAlert = false
    
    @Binding var flowState: SplitterFlowState
    @Binding var currency: Currency
    
    @Environment(\.displayScale) private var displayScale
    @State private var zoomScale: OCRResultsFrame.ZoomScale = .zoom1x
    
    private var imageScale: Double {
        1 / displayScale * zoomScale.rawValue
    }
    
    private var isNextButtonEnabled: Bool {
        !flowState.isReceiptStageIncomplete
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
    
    private func addPairToActiveItem(_ name: String, _ price: Double) {
        var itemToEdit = Item.Initiation()
        do {
            try itemToEdit.setPrice(to: price)
            itemToEdit.name = name
        } catch {
            if case Item.AssignmentError.itemPriceZero = error {
                isShowingPriceZeroAlert = true
                return
            }
        }
        
        if let completedItem = Item(from: itemToEdit) {
            flowState.items.append(completedItem)
            floatingBarState = .minimized
        }
    }
    
    var body: some View {
        ZStack {
            switch imagePickerItem {
            case .success(let uiImage):
                ScrollView([.horizontal, .vertical]) {
                    OCRResultsFrame(
                        uiImage: uiImage,
                        ocrResults: ocrResults,
                        imageScale: imageScale,
                        shouldShowOCRText: isShowingOCRLabels,
                        addResultToActiveItem: addResultToActiveItem(_:),
                        addPairToActiveItem: addPairToActiveItem(_:_:)
                    )
                }
                .ignoresSafeArea()
                if ocrResults.isEmpty {
                    Text("No text detected from image.")
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.ultraThinMaterial)
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
                    .foregroundStyle(.white)
            }
        }
        .background(Color(.secondarySystemBackground))
        .overlay(alignment: .bottom) {
            ImageViewerButtons(
                isImageToolbarEnabled: !ocrResults.isEmpty,
                isShowingOCRLabels: $isShowingOCRLabels,
                zoomScale: $zoomScale
            )
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                ReceiptStageNavBar(
                    isNextButtonEnabled: isNextButtonEnabled,
                    imagePickerItem: $imagePickerItem,
                    path: $path
                )
            }
        }
        .overlay(alignment: .topLeading) {
            CurrencyPicker(currency: $currency)
                .padding()
        }
        .overlay(alignment: .topTrailing) {
            VStack {
                TotalCostField(value: $flowState.totalCost, currency: currency, areOCRResultsAvailable: !ocrResults.isEmpty)
                FloatingItemsList(items: $flowState.items, state: $floatingBarState, currency: currency, shouldReturnToItemListSheet: ocrResults.isEmpty)
            }
            .padding()
        }
        .onChange(of: imagePickerItem) {
            ocrResults = []
            floatingBarState = .minimized
            if case .success(let uiImage) = imagePickerItem {
                runOCR(image: uiImage)
            }
        }
        .animation(.easeInOut, value: floatingBarState)
        .animation(.easeInOut, value: zoomScale)
        .statusBarHidden(imagePickerItem.hasDisplayImage)
        .alert("Invalid price: 0 is not allowed", isPresented: $isShowingPriceZeroAlert) {}
    }
    
    func processResults(_ results: [OCRResult]) {
        ocrResults = results
    }
}

private struct ImageViewerButtons: View {
    let isImageToolbarEnabled: Bool
    @Binding var isShowingOCRLabels: Bool
    @Binding var zoomScale: OCRResultsFrame.ZoomScale
    
    var body: some View {
        if isImageToolbarEnabled {
            HStack(spacing: 0) {
                Button {
                    isShowingOCRLabels.toggle()
                } label: {
                    Label(
                        isShowingOCRLabels ? "Hide OCR Labels" : "Show OCR Labels",
                        systemImage: isShowingOCRLabels ? "eye" : "eye.slash"
                    )
                    .labelStyle(.iconOnly)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                }
                .foregroundStyle(.primary)
                Divider()
                HStack {
                    Label("Zoom Scale", systemImage: "plus.magnifyingglass")
                        .labelStyle(.iconOnly)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                    Picker(selection: $zoomScale) {
                        ForEach(OCRResultsFrame.ZoomScale.allCases, id: \.self) { scaleCase in
                            Text("\(scaleCase.rawValue.formatted(.number.precision(.fractionLength(1))))x")
                                .monospacedDigit()
                                .tag(scaleCase)
                        }
                    } label: {
                        Label("Zoom Scale", systemImage: "plus.magnifyingglass")
                            .labelStyle(.iconOnly)
                    }
                }
                .tint(.primary)
            }
            .fixedSize(horizontal: false, vertical: true)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.regularMaterial)
            )
            .padding()
        }
    }
}

#Preview {
    StageSwitcherView(flowState: .sampleData)
}
