//
//  ResultsStage.swift
//  Splitter
//
//  Created by Vincent C. on 10/1/23.
//

import SwiftUI

struct ResultsStage: View {
    @Binding var stage: Stage
    @Binding var path: [InfoEntryStage]
    @Binding var flowState: SplitterFlowState
    let currency: Currency
    
    @Binding var imagePickerItem: ImagePickerItem
    @Binding var ocrResults: [OCRResult]
    
    private let animationDelayPerRow = 0.2
    
    @State private var showsDetailedSteps = false
    
    private func startOver() {
        stage = .infoEntry
        path = []
        flowState = .init()
        imagePickerItem = .empty
        ocrResults = []
    }
    
    private var result: CalculationResult? {
        guard let totalCost = flowState.totalCost else {
            return nil
        }
        return .init(
            totalCost: totalCost,
            payers: flowState.payers,
            items: flowState.items,
            shares: flowState.shares
        )
    }
    
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                if let result {
                    ForEach(result.payers.indices, id: \.self) { i in
                        ResultsRow(
                            payer: result.payers[i],
                            multiplier: result.multiplier,
                            totalCost: result.totalCost,
                            currency: currency,
                            animationDelay: Double(i) * animationDelayPerRow,
                            showsDetailedSteps: showsDetailedSteps
                        )
                    }
                    Divider()
                    if showsDetailedSteps {
                        HStack {
                            Text("RATIO: ")
                            Spacer()
                            Text(result.multiplier.formatted())
                                .bold()
                                .textSelection(.enabled)
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                        HStack {
                            Text("Subtotal: ")
                            Spacer()
                            Text((result.totalCost / result.multiplier).formatted(.currency(code: currency.rawValue)))
                                .bold()
                                .textSelection(.enabled)
                        }
                        .font(.title2)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                    }
                    HStack {
                        Text("Total: ")
                        Spacer()
                        Text(result.totalCost.formatted(.currency(code: currency.rawValue)))
                            .bold()
                            .textSelection(.enabled)
                    }
                    .font(.title2)
                    .padding(.horizontal)
                }
            }
            .padding()
        }
        .monospacedDigit()
        .animation(.easeInOut, value: showsDetailedSteps)
        .navigationTitle("Your results")
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                ResultsStageNavBar(stage: $stage, startOver: startOver)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(showsDetailedSteps ? "Hide Steps" : "Show Steps") {
                    showsDetailedSteps.toggle()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ResultsStage(
            stage: .constant(.calculated),
            path: .constant([.assignPayers]),
            flowState: .constant(.sampleData),
            currency: .usd,
            imagePickerItem: .constant(.empty),
            ocrResults: .constant([])
        )
    }
}
