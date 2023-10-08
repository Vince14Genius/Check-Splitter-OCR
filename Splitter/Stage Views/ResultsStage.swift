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
        NavigationStack {
            ScrollView(.vertical) {
                VStack {
                    ForEach(result?.payers ?? [], id: \.self) { payer in
                        VStack {
                            HStack {
                                Text(payer.name)
                                Spacer()
                                Text(payer.payerTotal.formatted(.currency(code: currency.rawValue)))
                                    .bold()
                                    .textSelection(.enabled)
                            }
                            .font(.title3)
                            
                            ForEach(payer.items, id: \.self) { item in
                                HStack {
                                    Text(item.name)
                                    Spacer()
                                    Text("× \(item.realQuantity.roundedToTwoPlaces)")
                                }
                            }
                            .foregroundStyle(.secondary)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                    Divider()
                    HStack {
                        Text("Total: ")
                        Spacer()
                        Text(result?.totalCost.formatted(.currency(code: currency.rawValue)) ?? "")
                            .bold()
                            .textSelection(.enabled)
                    }
                    .font(.title2)
                    .padding(.horizontal)
                }
                .padding()
            }
            .navigationTitle("Your results")
            .monospacedDigit()
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                ResultsStageNavBar(stage: $stage, path: $path, flowState: $flowState)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ResultsStage(stage: .constant(.calculated), path: .constant([.assignPayers]), flowState: .constant(.sampleData), currency: .usd)
    }
}
