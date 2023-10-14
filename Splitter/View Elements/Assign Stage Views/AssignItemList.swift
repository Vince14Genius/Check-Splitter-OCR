//
//  AssignItemList.swift
//  Splitter
//
//  Created by Vincent C. on 10/12/23.
//

import SwiftUI

struct AssignItemList: View {
    @Binding var flowState: SplitterFlowState
    @Binding var editMode: EditMode
    let currency: Currency
    let createNewPayer: () -> Payer
    
    @State private var multiSelection = Set<Item>()
    
    var body: some View {
        List(selection: $multiSelection) {
            if flowState.shouldShowItemSubtotalZeroWarning {
                Label {
                    Text("The subtotal of assigned items cannot be zero.")
                } icon: {
                    Image(systemName: "exclamationmark.triangle.fill")
                }
                .foregroundStyle(.red)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
            ForEach($flowState.items) { $item in
                ItemRow(
                    flowState: $flowState,
                    item: $item,
                    currency: currency
                ) {
                    flowState.shares.append(
                        .init(payerID: createNewPayer().id, itemID: item.id)
                    )
                }
                .tag(item)
            }
        }
        .toolbar {
            if editMode.isEditing {
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Text("\(multiSelection.count) selected")
                        Spacer()
                        MultiSelectNewPayerButton(
                            items: multiSelection,
                            flowState: $flowState,
                            editMode: $editMode,
                            createNewPayer: createNewPayer
                        )
                    }
                }
            }
        }
    }
}

private struct MultiSelectNewPayerButton: View {
    let items: Set<Item>
    @Binding var flowState: SplitterFlowState
    @Binding var editMode: EditMode
    let createNewPayer: () -> Payer
    
    var body: some View {
        Button("New payer with selected") {
            let newPayer = createNewPayer()
            items.forEach {
                flowState.shares.append(.init(
                    payerID: newPayer.id, itemID: $0.id
                ))
            }
            editMode = .inactive
        }
        .disabled(items.isEmpty)
    }
}

#Preview {
    NavigationStack {
        AssignStage(stage: .constant(.infoEntry), path: .constant([.assignPayers]), flowState: .constant(.sampleData), currency: .try)
    }
}
