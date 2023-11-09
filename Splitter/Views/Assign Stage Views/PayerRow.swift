import SwiftUI

struct PayerRow: View {
    @Binding var flowState: SplitterFlowState
    @Binding var payer: Payer
    
    @State private var indexOfShareToEdit: [Share].Index?
    
    @State private var isPresentingPayerEditorSheet = false
    
    private var items: [Item] {
        flowState.items.filter { item in
            flowState.shares.filter { share in
                share.payerID == payer.id
            }.contains {
                $0.itemID == item.id
            }
        }
    }
    
    @Environment(\.editMode) private var editMode
    private var isEditing: Bool {
        editMode?.wrappedValue.isEditing ?? false
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(payer.name)
                    .font(.title2)
                Button {
                    isPresentingPayerEditorSheet = true
                } label: {
                    Label("Edit payer", systemImage: "pencil")
                        .labelStyle(.iconOnly)
                }
                .buttonStyle(.borderless)
                .disabled(isEditing)
                Spacer()
                Text("\(items.count) items")
                    .foregroundStyle(items.isEmpty && isEditing ? .red : .secondary)
                    .font(.body.monospacedDigit())
            }
            HStack(alignment: .bottom) {
                if items.isEmpty {
                    Label("No items assigned", systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                        .font(.caption)
                } else {
                    ItemShareList(
                        payer: payer,
                        items: items,
                        flowState: $flowState,
                        indexOfShareToEdit: $indexOfShareToEdit
                    )
                }
                Spacer()
                CreateShareMenu(
                    payer: payer,
                    assignedItems: items,
                    indexOfShareToEdit: $indexOfShareToEdit,
                    flowState: $flowState
                )
                .buttonStyle(.bordered)
            }
            .disabled(isEditing)
        }
        .id(payer.id)
        .selectionDisabled(!isEditing)
        .sheet(isPresented: $isPresentingPayerEditorSheet) {
            PayerEditor(
                payer: $payer,
                flowState: $flowState
            ) {
                isPresentingPayerEditorSheet = false
            }
            .presentationDetents([.medium])
            .presentationBackground(.thinMaterial)
            .interactiveDismissDisabled()
        }
        .sheet(item: $indexOfShareToEdit) { i in
            QuantityEditorSheet(
                itemName: items.first { $0.id == flowState.shares[i].itemID }?.name ?? "-",
                payerName: payer.name,
                share: $flowState.shares[i]
            ) {
                indexOfShareToEdit = nil
            } unassignAction: {
                if let indexOfShareToEdit {
                    flowState.shares.remove(at: indexOfShareToEdit)
                }
            }
        }
    }
}

private struct ItemShareList: View {
    let payer: Payer
    let items: [Item]
    @Binding var flowState: SplitterFlowState
    @Binding var indexOfShareToEdit: [Share].Index?
    
    var body: some View {
        VStack(alignment: .leading) {
            if flowState.isSubtotalNegative(for: payer) {
                Label("The subtotal for this payer is negative", systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
                    .font(.caption2)
            }
            ForEach(items) { item in
                ShareButton(
                    title: item.name,
                    itemID: item.id,
                    payerID: payer.id,
                    flowState: $flowState,
                    indexOfShareToEdit: $indexOfShareToEdit
                )
            }
        }
    }
}

private struct CreateShareMenu: View {
    let payer: Payer
    let assignedItems: [Item]
    @Binding var indexOfShareToEdit: [Share].Index?
    @Binding var flowState: SplitterFlowState
    
    @State private var isPresentingMultiSelectMenu = false
    
    var body: some View {
        Menu {
            Section {
                Button("Select Multiple") {
                    isPresentingMultiSelectMenu = true
                }
            }
            Section {
                ForEach(flowState.items) { item in
                    Button(item.name) {
                        let newShare = Share(payerID: payer.id, itemID: item.id)
                        flowState.shares.append(newShare)
                        let i = flowState.shares.firstIndex {
                            $0.id == newShare.id
                        }!
                        indexOfShareToEdit = i
                    }
                    .disabled(assignedItems.contains{ $0.id == item.id })
                }
            }
        } label: {
            Label("Assign item", systemImage: "plus")
                .labelStyle(.iconOnly)
        }
        .disabled(assignedItems.count == flowState.items.count)
        .sheet(isPresented: $isPresentingMultiSelectMenu) {
            MultiSelectSheet(
                data: .items(payer: payer),
                flowState: $flowState,
                isPresenting: $isPresentingMultiSelectMenu
            )
        }
    }
}

private struct PayerRow_PreviewWrapper: View {
    @State private var data = SplitterFlowState.sampleData
    
    var body: some View {
        List {
            ForEach(SplitterFlowState.sampleData.payers) { payer in
                PayerRow(flowState: $data, payer: .constant(payer))
            }
        }
    }
}

#Preview {
    PayerRow_PreviewWrapper()
}
