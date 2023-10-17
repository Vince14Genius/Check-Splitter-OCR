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
    
    var body: some View {
        switch stage {
        case .infoEntry:
            NavigationStack(path: $enterInfoStagePath) {
                ReceiptStage(stage: $stage, path: $enterInfoStagePath, flowState: $flowState, currency: $currency)
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
                ResultsStage(stage: $stage, path: $enterInfoStagePath, flowState: $flowState, currency: currency)
            }
        }
    }
}

#Preview {
    StageSwitcherView(flowState: .sampleData)
}
