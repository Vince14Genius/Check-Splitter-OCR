//
//  AssignPayerList.swift
//  Splitter
//
//  Created by Vincent C. on 10/12/23.
//

import SwiftUI

struct AssignPayerList: View {
    @Binding var flowState: SplitterFlowState
    
    var body: some View {
        List {
            if flowState.payers.isEmpty {
                HStack {
                    Spacer()
                    Label {
                        Text("No payers yet.")
                    } icon: {
                        Image(systemName: "exclamationmark.triangle.fill")
                    }
                    .foregroundStyle(.red)
                    Spacer()
                }
            }
            ForEach($flowState.payers) { $payer in
                PayerRow(flowState: $flowState, payer: $payer)
            }
            .onDelete { flowState.payers.remove(atOffsets: $0) }
            .onMove { flowState.payers.move(fromOffsets: $0, toOffset: $1) }
        }
    }
}

#Preview {
    NavigationStack {
        AssignStage(stage: .constant(.infoEntry), path: .constant([.assignPayers]), flowState: .constant(.sampleData), currency: .try)
    }
}
