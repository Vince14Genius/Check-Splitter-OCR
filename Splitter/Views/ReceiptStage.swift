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
    
    @Binding var flowState: SplitterFlowState
    @Binding var currency: Currency
    
    @Binding var imagePickerItem: ImagePickerItem
    @Binding var ocrResults: [OCRResult]
    
    @State private var isShowingOCRLabels = true
    @State private var floatingBarState: FloatingBarState = .minimized
    
    @State private var isShowingPriceZeroAlert = false
    
    @Environment(\.displayScale) private var displayScale
    @State private var zoomScale: OCRResultsFrame.ZoomScale = .zoom1x
    
    private var imageScale: Double {
        1 / displayScale * zoomScale.rawValue
    }
    
    private var isNextButtonEnabled: Bool {
        !flowState.isReceiptStageIncomplete
    }
    
    // MARK: main body
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
                        totalCost: $flowState.totalCost,
                        addResultToActiveItem: addResultToActiveItem(_:),
                        addPairToActiveItem: addPairToActiveItem(_:_:)
                    )
                }
                .simultaneousGesture(MagnifyGesture().onEnded { value in
                    zoomScale = zoomScale.advanced(by: value.magnification > 1 ? 1 : -1)
                })
                .simultaneousGesture(TapGesture(count: 2).onEnded {
                    zoomScale = zoomScale.rotated()
                })
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
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                        Image(systemName: "text.viewfinder")
                            .font(.title)
                            .padding(.bottom)
                        Text("Scan a receipt to start")
                            .font(.headline)
                        Text("Or enter items manually")
                        Spacer()
                        Spacer()
                        Spacer()
                        if !imagePickerItem.hasDisplayImage {
                            CameraPicker(imageItem: $imagePickerItem)
                                .labelStyle(.titleAndIcon)
                                .buttonStyle(.borderedProminent)
                                .padding()
                            PhotoLibraryPicker(imageItem: $imagePickerItem)
                                .labelStyle(.titleAndIcon)
                        }
                        Spacer()
                    }
                }
            case .failure:
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.white)
            }
        }
        .background(Color(.secondarySystemBackground))
        // MARK: overlays & toolbars
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
        .overlay(alignment: .bottom) {
            ImageViewerControls(
                isImageToolbarEnabled: !ocrResults.isEmpty,
                isShowingOCRLabels: $isShowingOCRLabels,
                zoomScale: $zoomScale
            )
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                ReceiptStageNavBar(
                    isNextButtonEnabled: isNextButtonEnabled,
                    areImagePickersNeeded: imagePickerItem.hasDisplayImage,
                    imagePickerItem: $imagePickerItem,
                    path: $path
                )
            }
        }
        // MARK: other modifiers
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
    
    // MARK: Process OCR results
    func processOCRResults(_ results: [OCRResult]) {
        ocrResults = results
    }
}

// MARK: Floating bar interactions
private extension ReceiptStage {
    func addResultToActiveItem(_ result: OCRResult) {
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
    
    func addPairToActiveItem(_ name: String, _ price: Double) {
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
}

// MARK: Preview
#Preview {
    StageSwitcherView(flowState: .sampleData)
}
