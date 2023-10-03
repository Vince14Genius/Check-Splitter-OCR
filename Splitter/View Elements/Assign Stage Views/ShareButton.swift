//
//  ShareButton.swift
//  Splitter
//
//  Created by Vincent C. on 10/2/23.
//

import SwiftUI

extension Array<Share>.Index: Identifiable {
    public typealias ID = Self
    public var id: ID {
        self
    }
}

struct ShareButton: View {
    let title: String
    let item: Item
    let payer: Payer
    @Binding var flowState: SplitterFlowState
    @Binding var indexOfShareToEdit: [Share].Index?
    
    var body: some View {
        if let i = flowState.shares.firstIndex(where: {
            $0.has(item) && $0.has(payer)
        }) {
            let share = flowState.shares[i]
            Menu {
                Button("Unassign \(title)") {
                    flowState.shares.removeAll { $0 == share }
                }
            } label: {
                HStack {
                    Text(title)
                    Text("× \(share.realQuantity.roundedToTwoPlaces)")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
            } primaryAction: {
                indexOfShareToEdit = i
            }
            .buttonStyle(.bordered)
            .foregroundStyle(.primary)
            .id(share.id)
        }
    }
}
