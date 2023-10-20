//
//  MultiSelectSheet.swift
//  Splitter
//
//  Created by Vincent C. on 10/19/23.
//

import SwiftUI

enum MultiSelectType {
    case items(payer: Payer)
    case payers(item: Item)
}

struct MultiSelectSheet: View {
    let data: MultiSelectType
    @Binding var flowState: SplitterFlowState
    @Binding var isPresenting: Bool
    
    @State private var multiSelection = Set<AnyHashable>()
    @State private var editMode: EditMode = .inactive
    
    private func hasShare(item: Item, payer: Payer) -> Bool {
        flowState.shares.contains {
            $0.itemID == item.id && $0.payerID == payer.id
        }
    }
    
    private func addShare(item: Item, payer: Payer) {
        guard !hasShare(item: item, payer: payer) else {
            return
        }
        flowState.shares.append(.init(
            payerID: payer.id,
            itemID: item.id
        ))
    }
    
    private func assign(
        item: Item,
        payers: Set<Payer>,
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
    
    private var navigationTitle: String {
        switch data {
        case .items(_):
            "Assign Items"
        case .payers(_):
            "Assign Payers"
        }
    }
    
    var body: some View {
        NavigationStack {
            List(selection: $multiSelection) {
                switch data {
                case .items(let payer):
                    ForEach(flowState.items) { item in
                        let shouldDisable = hasShare(item: item, payer: payer)
                        HStack {
                            if shouldDisable {
                                Image(systemName: "checkmark")
                            }
                            Text(item.name)
                        }
                        .tag(item as AnyHashable)
                        .selectionDisabled(shouldDisable)
                        .foregroundStyle(shouldDisable ? .secondary : .primary)
                    }
                case .payers(let item):
                    ForEach(flowState.payers) { payer in
                        let shouldDisable = hasShare(item: item, payer: payer)
                        HStack {
                            if shouldDisable {
                                Image(systemName: "checkmark")
                            }
                            Text(payer.name)
                        }
                        .tag(payer as AnyHashable)
                        .selectionDisabled(shouldDisable)
                        .foregroundStyle(shouldDisable ? .secondary : .primary)
                    }
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    let title: String = switch data {
                    case .items(let payer):
                        payer.name
                    case .payers(let item):
                        item.name
                    }
                    VStack {
                        Text(navigationTitle)
                        Text(title)
                            .foregroundStyle(.secondary)
                            .font(.caption2)
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        isPresenting = false
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    switch data {
                    case .items(let payer):
                        let items = multiSelection as! Set<Item>
                        Button("Assign") {
                            defer { isPresenting = false }
                            for item in items {
                                addShare(item: item, payer: payer)
                            }
                        }
                        .bold()
                        .disabled(multiSelection.isEmpty)
                    case .payers(let item):
                        let payers = multiSelection as! Set<Payer>
                        Menu("Assign") {
                            Button("Assign 1 each") {
                                defer { isPresenting = false }
                                assign(
                                    item: item,
                                    payers: payers,
                                    wholeNumberQuantity: 1,
                                    fractionPartNumerator: 0,
                                    fractionPartDenominator: 1
                                )
                            }
                            Button("Divide 1 evenly") {
                                defer { isPresenting = false }
                                assign(
                                    item: item,
                                    payers: payers,
                                    wholeNumberQuantity: 0,
                                    fractionPartNumerator: 1,
                                    fractionPartDenominator: payers.count
                                )
                            }
                        }
                        .bold()
                        .disabled(multiSelection.isEmpty)
                    }
                }
            }
            .environment(\.editMode, $editMode)
            .onAppear {
                editMode = .active
            }
        }
        .presentationBackground(.thinMaterial)
        .presentationDetents([.medium])
    }
}

struct MultiSelectSheet_PreviewWrapper: View {
    let data: MultiSelectType
    @State private var isPresentingSheet = false
    
    var body: some View {
        Button("Sheet") {
            isPresentingSheet.toggle()
        }
        .sheet(isPresented: $isPresentingSheet) {
            MultiSelectSheet(
                data: data,
                flowState: .constant(.sampleData),
                isPresenting: $isPresentingSheet
            )
        }
    }
}

#Preview {
    MultiSelectSheet_PreviewWrapper(data: .items(payer: SplitterFlowState.sampleData.payers[1]))
}

#Preview {
    MultiSelectSheet_PreviewWrapper(data: .payers(item: SplitterFlowState.sampleData.items[1]))
}
