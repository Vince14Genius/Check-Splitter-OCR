//
//  StageSwitcherView.swift
//  Splitter
//
//  Created by Vincent C. on 9/26/23.
//

import SwiftUI

struct StageSwitcherView: View {
    @State private var stage: Stage = .receipt
    @AppStorage("currency", store: .standard) var currency: Currency = .usd
    @State var flowState: SplitterFlowState = .init()
    
    var body: some View {
        switch stage {
        case .receipt:
            ReceiptStage(stage: $stage, flowState: $flowState, currency: $currency)
        case .assignPayers:
            AssignStage(stage: $stage, flowState: $flowState, currency: currency)
        case .calculated:
            ResultsStage(stage: $stage, flowState: $flowState, currency: currency)
        }
    }
}

#Preview {
    StageSwitcherView(flowState: .sampleData)
}
