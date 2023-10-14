//
//  AssignPayerList.swift
//  Splitter
//
//  Created by Vincent C. on 10/12/23.
//

import SwiftUI

struct AssignPayerList: View {
    @Binding var flowState: SplitterFlowState
    @Binding var editMode: EditMode
    
    @State private var multiSelection = Set<Payer>()
    
    var body: some View {
        List(selection: $multiSelection) {
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
                    .tag(payer)
            }
            .onDelete { flowState.payers.remove(atOffsets: $0) }
            .onMove { flowState.payers.move(fromOffsets: $0, toOffset: $1) }
        }
        .toolbar {
            if editMode.isEditing {
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Text("\(multiSelection.count) selected")
                        Spacer()
                        AssignItemMenu(
                            payers: multiSelection,
                            flowState: $flowState,
                            editMode: $editMode
                        )
                    }
                }
            }
        }
    }
}

private struct AssignItemMenu: View {
    let payers: Set<Payer>
    @Binding var flowState: SplitterFlowState
    @Binding var editMode: EditMode
    
    @State private var isPresentingOptionsAlert = false
    @State private var item: Item!
    
    private func assign(
        wholeNumberQuantity: Int,
        fractionPartNumerator: Int,
        fractionPartDenominator: Int
    ) {
        payers.forEach { payer in
            flowState.shares.removeAll {
                $0.payerID == payer.id &&
                $0.itemID == item.id
            }
            flowState.shares.append(.init(
                payerID: payer.id,
                itemID: item.id,
                wholeNumberQuantity: wholeNumberQuantity,
                fractionPartNumerator: fractionPartNumerator,
                fractionPartDenominator: fractionPartDenominator
            ))
        }
        editMode = .inactive
    }
    
    var body: some View {
        Menu("Assign Item") {
            Section {
                ForEach(flowState.items) { item in
                    Button(item.name) {
                        isPresentingOptionsAlert = true
                        self.item = item
                    }
                }
            }
        }
        .disabled(payers.isEmpty)
        .alert("Choose quantity per payer", isPresented: $isPresentingOptionsAlert) {
            Button("Assign 1 each") {
                assign(wholeNumberQuantity: 1, fractionPartNumerator: 0, fractionPartDenominator: 1)
            }
            Button("Divide 1 evenly") {
                assign(wholeNumberQuantity: 0, fractionPartNumerator: 1, fractionPartDenominator: payers.count)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You can edit the quantities manually afterwards.")
        }
    }
}

#Preview {
    NavigationStack {
        AssignStage(stage: .constant(.infoEntry), path: .constant([.assignPayers]), flowState: .constant(.sampleData), currency: .try)
    }
}
