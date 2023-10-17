//
//  ResultsRow.swift
//  Splitter
//
//  Created by Vincent C. on 10/16/23.
//

import SwiftUI

struct ResultsRow: View {
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
