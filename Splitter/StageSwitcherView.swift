//
//  StageSwitcherView.swift
//  Splitter
//
//  Created by Vincent C. on 9/26/23.
//

import SwiftUI

struct StageSwitcherView: View {
    @State private var stage: Stage = .infoEntry
    @AppStorage("currency", store: .standard) var currency: Currency = .usd
    @State var flowState: SplitterFlowState = .init()
    @State private var enterInfoStagePath: [InfoEntryStage] = []
    
    // receipt stage OCR persistence
    @State private var imagePickerItem: ImagePickerItem = .empty
    @State private var ocrResults: [OCRResult] = []
    
    var body: some View {
        switch stage {
        case .infoEntry:
            NavigationStack(path: $enterInfoStagePath) {
                ReceiptStage(
                    stage: $stage,
                    path: $enterInfoStagePath,
                    flowState: $flowState,
                    currency: $currency,
                    imagePickerItem: $imagePickerItem,
                    ocrResults: $ocrResults
                )
                .navigationDestination(for: InfoEntryStage.self) { infoEntryStage in
                    switch infoEntryStage {
                    case .assignPayers:
                        AssignStage(stage: $stage, path: $enterInfoStagePath, flowState: $flowState, currency: currency)
                            .navigationBarBackButtonHidden()
                    }
                }
            }
        case .calculated:
            NavigationStack {
                ResultsStage(
                    stage: $stage,
                    path: $enterInfoStagePath,
                    flowState: $flowState,
                    currency: currency,
                    imagePickerItem: $imagePickerItem,
                    ocrResults: $ocrResults
                )
            }
        }
    }
}

#Preview {
    StageSwitcherView(flowState: .sampleData)
}
