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
    
    @State private var showsDetailedSteps = false
    
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
            .navigationTitle("Your results")
            .monospacedDigit()
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                ResultsStageNavBar(stage: $stage, path: $path, flowState: $flowState)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(showsDetailedSteps ? "Hide Steps" : "Show Steps") {
                    showsDetailedSteps.toggle()
                }
            }
        }
        .animation(.easeInOut, value: showsDetailedSteps)
    }
}

private struct ResultsRow: View {
    let payer: ResultPayer
    let multiplier: Double
    let totalCost: Double
    let currency: Currency
    let animationDelay: TimeInterval
    let showsDetailedSteps: Bool
    
    @State private var isVisible = false
    @Environment(\.layoutDirection) private var layoutDirection
    
    private var arrowSymbol: String {
        switch layoutDirection {
        case .leftToRight: "→"
        case .rightToLeft: "←"
        @unknown default: "becomes"
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(payer.name)
                Spacer()
                if showsDetailedSteps {
                    Text((payer.payerTotal / multiplier).formatted(.currency(code: currency.rawValue)))
                        .bold()
                        .foregroundStyle(.secondary)
                }
                Text(payer.payerTotal.formatted(.currency(code: currency.rawValue)))
                    .bold()
                    .textSelection(.enabled)
            }
            .font(.title3)
            
            if showsDetailedSteps {
                Divider()
                HStack {
                    Spacer()
                    Text("\((payer.payerTotal / totalCost).formatted(.percent)) OF TOTAL")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            ForEach(payer.items, id: \.self) { item in
                if showsDetailedSteps {
                    Divider()
                }
                
                HStack {
                    Text(item.name)
                    Spacer()
                    if showsDetailedSteps {
                        Text(item.originalUnitPrice.formatted(.currency(code: currency.rawValue)))
                            .bold()
                            .foregroundStyle(.secondary)
                    }
                    Text("× \(item.realQuantity.roundedToTwoPlaces)")
                }
                .foregroundStyle(showsDetailedSteps ? .primary : .secondary)
                
                if showsDetailedSteps {
                    HStack {
                        Text(arrowSymbol)
                        Text(item.originalSharePrice.formatted(.currency(code: currency.rawValue)))
                        Text("× \(multiplier)")
                            .foregroundStyle(.tertiary)
                        Spacer()
                        Text(arrowSymbol)
                        Text(item.finalPrice(multiplier: multiplier).formatted(.currency(code: currency.rawValue)))
                            .bold()
                    }
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
