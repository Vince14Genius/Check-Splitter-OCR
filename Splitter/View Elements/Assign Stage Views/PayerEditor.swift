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
        shares.filter { $0.has(payer) }
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
                            share.has(payer),
                            let item = items.first(where: { share.has($0) })
                        {
                            HStack {
                                Text(item.name)
                                Spacer()
                                Button("× \(share.realQuantity.roundedToTwoPlaces)") {
                                    indexOfShareToEdit = shares.firstIndex {
                                        $0 == share
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
                                shares.append(.from(item: item, payer: payer))
                                indexOfShareToEdit = shares.count - 1
                            }
                            .disabled(currentPayerShares.contains { $0.has(item) })
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
                    itemName: items.first { shares[i].has($0) }?.name ?? "-",
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
