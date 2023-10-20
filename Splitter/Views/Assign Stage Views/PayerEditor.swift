//
//  PayerEditor.swift
//  Splitter
//
//  Created by Vincent C. on 9/30/23.
//

import SwiftUI

struct PayerEditor: View {
    @Binding var payer: Payer
    @Binding var flowState: SplitterFlowState
    let dismissAction: () -> Void
    
    @FocusState private var isNameFieldFocused: Bool
    @State private var shareToEdit: Share?
    
    @State private var isPresentingMultiSelectMenu = false
    
    private var currentPayerShares: [Share] {
        flowState.shares.filter { $0.payerID == payer.id }
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
                                Label("Unfocus keyboard", image: "checkmark.circle")
                                    .labelStyle(.iconOnly)
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
                    ForEach(flowState.shares) { share in
                        if
                            share.payerID == payer.id,
                            let item = flowState.items.first(where: { $0.id == share.itemID })
                        {
                            HStack {
                                Text(item.name)
                                Spacer()
                                Button("× \(share.realQuantity.roundedToTwoPlaces)") {
                                    shareToEdit = share
                                }
                                .buttonStyle(.bordered)
                                .foregroundStyle(.primary)
                            }
                        }
                    }
                    .onDelete { flowState.shares.remove(atOffsets: $0) }
                }
                .listStyle(.plain)
                .padding(.bottom)
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        EditButton()
                        Spacer()
                        Menu {
                            Section {
                                Button("Select Multiple") {
                                    isPresentingMultiSelectMenu = true
                                }
                            }
                            Section {
                                ForEach(flowState.items) { item in
                                    Button(item.name) {
                                        let share = Share(payerID: payer.id, itemID: item.id)
                                        flowState.shares.append(share)
                                        shareToEdit = share
                                    }
                                    .disabled(currentPayerShares.contains { $0.itemID == item.id })
                                }
                            }
                        } label: {
                            Label("Assign item", systemImage: "plus")
                                .labelStyle(.iconOnly)
                        }
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Done", action: dismissAction)
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
            .sheet(item: $shareToEdit) { share in
                QuantityEditorSheet(
                    itemName: flowState.items.first { $0.id == share.itemID }?.name ?? "-",
                    payerName: payer.name,
                    share: $flowState.shares[flowState.shares.firstIndex { $0.id == share.id }!]
                ) {
                    shareToEdit = nil
                }
            }
            .sheet(isPresented: $isPresentingMultiSelectMenu) {
                MultiSelectSheet(
                    data: .items(payer: payer),
                    flowState: $flowState,
                    isPresenting: $isPresentingMultiSelectMenu
                )
            }
        }
    }
}

#Preview {
    PayerEditor(
        payer: .constant(SplitterFlowState.sampleData.payers[0]),
        flowState: .constant(SplitterFlowState.sampleData)
    ) {}
}

#Preview {
    PayerEditor(
        payer: .constant(SplitterFlowState.sampleData.payers[0]),
        flowState: .constant(.init())
    ) {}
}

#Preview {
    PayerEditor(
        payer: .constant(.init(name: "")),
        flowState: .constant(.init())
    ) {}
}
