import SwiftUI

struct PayerRow: View {
    @Binding var flowState: SplitterFlowState
    @Binding var payer: Payer
    
    @Environment(\.editMode) private var editMode
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
    
    private var isEditing: Bool {
        return editMode?.wrappedValue.isEditing ?? false
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                NameLabel(payer.name)
                    .font(.title2)
                Spacer()
                Text("\(items.count) items")
                    .foregroundStyle(items.isEmpty && isEditing ? .red : .secondary)
                    .font(.body.monospacedDigit())
            }
            if !isEditing {
                HStack {
                    if items.isEmpty {
                        Label("No items assigned", systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                        Spacer()
                    } else {
                        ItemShareList(
                            payer: payer,
                            items: items,
                            flowState: $flowState,
                            indexOfShareToEdit: $indexOfShareToEdit
                        )
                    }
                    Spacer()
                    Button {
                        isPresentingPayerEditorSheet = true
                    } label: {
                        Image(systemName: "pencil")
                    }
                    CreateShareMenu(
                        payer: payer,
                        assignedItems: items,
                        indexOfShareToEdit: $indexOfShareToEdit,
                        flowState: $flowState
                    )
                }
            }
        }
        .id(payer.id)
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
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
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
}

private struct CreateShareMenu: View {
    let payer: Payer
    let assignedItems: [Item]
    @Binding var indexOfShareToEdit: [Share].Index?
    @Binding var flowState: SplitterFlowState
    
    var body: some View {
        Menu {
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
            Image(systemName: "plus")
        }
        .disabled(assignedItems.count == flowState.items.count)
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
