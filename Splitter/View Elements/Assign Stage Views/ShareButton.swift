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
    let itemID: Item.ID
    let payerID: Payer.ID
    @Binding var flowState: SplitterFlowState
    @Binding var indexOfShareToEdit: [Share].Index?
    
    var body: some View {
        if let i = flowState.shares.firstIndex(where: {
            $0.itemID == itemID &&
            $0.payerID == payerID
        }) {
            Button{
                indexOfShareToEdit = i
            } label: {
                HStack {
                    Text(title)
                    Text("× \(flowState.shares[i].realQuantity.roundedToTwoPlaces)")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
            }
            .buttonStyle(.bordered)
            .foregroundStyle(.primary)
            .contextMenu {
                Button("Unassign \(title)") {
                    flowState.shares.remove(at: i)
                }
            }
        }
    }
}
