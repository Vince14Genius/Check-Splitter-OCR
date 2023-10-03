//
//  PayerEditor.swift
//  Splitter
//
//  Created by Vincent C. on 9/30/23.
//

import SwiftUI

struct PayerEditor: View {
    @Binding var payer: Payer
    @Binding var shares: [Share]
    let items: [Item]
    let dismissAction: () -> Void
    
    @FocusState private var isNameFieldFocused: Bool
    @State private var indexOfShareToEdit: [Share].Index?
    
    private var currentPayerShares: [Share] {
        shares.filter { $0.payerID == payer.id }
    }
    
    private var isInvalid: Bool { payer.name.isEmpty }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(alignment: .leading) {
                    Text("Payer")
                        .fontWeight(.light)
                    HStack {
                        VStack {
                            TextField("Payer Name", text: $payer.name)
                                .font(.title2)
                                .bold()
                                .focused($isNameFieldFocused)
                            Divider()
                        }
                        if isNameFieldFocused {
                            Button {
                                isNameFieldFocused = false
                            } label: {
                                Image(systemName: "checkmark.circle")
                            }
                            .font(.title2)
                            .disabled(payer.name.isEmpty)
                        }
                    }
                    Text("Item Shares")
                        .font(.body.smallCaps())
                        .foregroundStyle(.secondary)
                }
                .padding([.top, .horizontal])
                Divider()
                List {
                    ForEach(shares) { share in
                        if
                            share.payerID == payer.id,
                            let item = items.first(where: { $0.id == share.itemID })
                        {
                            HStack {
                                Text(item.name)
                                Spacer()
                                Button("× \(share.realQuantity.roundedToTwoPlaces)") {
                                    indexOfShareToEdit = shares.firstIndex {
                                        $0.id == share.id
                                    }
                                }
                                .buttonStyle(.bordered)
                                .foregroundStyle(.primary)
                            }
                        }
                    }
                    .onDelete { shares.remove(atOffsets: $0) }
                }
                .listStyle(.plain)
                .padding(.bottom)
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    EditButton()
                }
                ToolbarItem(placement: .bottomBar) {
                    Menu {
                        ForEach(items) { item in
                            Button(item.name) {
                                shares.append(.init(payerID: payer.id, itemID: item.id))
                                indexOfShareToEdit = shares.count - 1
                            }
                            .disabled(currentPayerShares.contains { $0.itemID == item.id })
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Done", action: dismissAction)
                        .buttonStyle(.borderedProminent)
                        .disabled(isInvalid)
                        .keyboardShortcut(.return, modifiers: .command)
                }
            }
            .onAppear {
                isNameFieldFocused = payer.name.isEmpty
            }
            .onTapGesture {
                isNameFieldFocused = false
            }
            .sheet(item: $indexOfShareToEdit) { i in
                QuantityEditorSheet(
                    itemName: items.first { $0.id == shares[i].itemID }?.name ?? "-",
                    payerName: payer.name,
                    share: $shares[i]
                ) {
                    indexOfShareToEdit = nil
                }
            }
        }
    }
}

#Preview {
    PayerEditor(
        payer: .constant(SplitterFlowState.sampleData.payers[0]),
        shares: .constant(SplitterFlowState.sampleData.shares),
        items: SplitterFlowState.sampleData.items
    ) {}
}

#Preview {
    PayerEditor(
        payer: .constant(SplitterFlowState.sampleData.payers[0]),
        shares: .constant([]),
        items: []
    ) {}
}

#Preview {
    PayerEditor(
        payer: .constant(.init(name: "")),
        shares: .constant([]),
        items: []
    ) {}
}
