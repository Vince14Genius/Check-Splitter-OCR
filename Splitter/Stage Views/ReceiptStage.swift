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
    
    @State private var viewModel = OCRPhotoModel()
    @State private var ocrResults: [OCRResult] = []
    
    @State private var isShowingOCRLabels = true
    @State private var floatingBarState: FloatingBarState = .minimized
    
    @Binding var flowState: SplitterFlowState
    @Binding var currency: Currency
    
    @Environment(\.displayScale) private var displayScale
    @State private var zoomScale: OCRResultsFrame.ZoomScale = .zoom1x
    
    private var imageScale: Double {
        1 / displayScale * zoomScale.rawValue
    }
    
    private var isNextButtonEnabled: Bool {
        !flowState.items.isEmpty && flowState.totalCost != nil
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
                    .foregroundColor(.white)
            }
        }
        .background(Color(.secondarySystemBackground))
        .overlay(alignment: .bottom) {
            ReceiptStageNavBar(
                isNextButtonEnabled: isNextButtonEnabled,
                isImageToolbarEnabled: !ocrResults.isEmpty,
                isShowingOCRLabels: $isShowingOCRLabels,
                zoomScale: $zoomScale,
                viewModel: $viewModel, 
                stage: $stage
            )
        }
        .overlay(alignment: .topLeading) {
            CurrencyPicker(currency: $currency)
                .padding()
        }
        .overlay(alignment: .topTrailing) {
            VStack {
                TotalCostField(value: $flowState.totalCost, currency: currency)
                FloatingItemsList(items: $flowState.items, state: $floatingBarState, currency: currency)
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
        .statusBarHidden({
            switch viewModel.imageState {
            case .success(_):
                true
            default:
                false
            }
        }())
        .transition(.move(edge: .leading).animation(.easeInOut))
    }
    
    func processResults(_ results: [OCRResult]) {
        ocrResults = results
    }
}

#Preview {
    StageSwitcherView(flowState: .sampleData)
}
