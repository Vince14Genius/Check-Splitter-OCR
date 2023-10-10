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
    
    private let animationDelayPerRow = 0.2
    
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
                    if let result {
                        ForEach(result.payers.indices, id: \.self) { i in
                            ResultsRow(
                                payer: result.payers[i],
                                currency: currency,
                                animationDelay: Double(i) * animationDelayPerRow
                            )
                        }
                        Divider()
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

private struct ResultsRow: View {
    let payer: ResultPayer
    let currency: Currency
    let animationDelay: TimeInterval
    
    @State private var isVisible = false
    
    var body: some View {
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
        .opacity(isVisible ? 1.0 : 0.0)
        .offset(x: isVisible ? 0.0 : -300.0)
        .onAppear {
            withAnimation(.bouncy.delay(animationDelay)) {
                isVisible = true
            }
        }
        .onDisappear {
            isVisible = false
        }
    }
}

#Preview {
    NavigationStack {
        ResultsStage(stage: .constant(.calculated), path: .constant([.assignPayers]), flowState: .constant(.sampleData), currency: .usd)
    }
}
