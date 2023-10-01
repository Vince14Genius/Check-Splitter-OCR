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
    @State private var shareToEdit: Binding<Share>?
    
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
                    ForEach($shares) { $share in
                        if
                            share.payerID == payer.id,
                            let item = items.first(where: { $0.id == share.itemID })
                        {
                            HStack {
                                Text(item.name)
                                Spacer()
                                Button("× \(String(format: "%.2f", share.realQuantity))") {
                                    shareToEdit = $share
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
                }
            }
            .onAppear {
                isNameFieldFocused = payer.name.isEmpty
            }
            .onTapGesture {
                isNameFieldFocused = false
            }
            .sheet(item: $shareToEdit) { $share in
                QuantityEditorSheet(
                    itemName: items.first { $0.id == share.itemID }?.name ?? "-",
                    payerName: payer.name,
                    share: $share
                ) {
                    shareToEdit = nil
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
