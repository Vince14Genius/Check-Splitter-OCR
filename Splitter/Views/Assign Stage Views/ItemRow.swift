import SwiftUI

struct ItemRow: View {
    @Binding var flowState: SplitterFlowState
    @Binding var item: Item
    @State private var isEditingPrice = false
    
    let currency: Currency
    var createNewPayerAction: (() -> Void)?
    
    @State private var indexOfShareToEdit: [Share].Index?
    
    @Environment(\.editMode) private var editMode
    private var isEditing: Bool {
        editMode?.wrappedValue.isEditing ?? false
    }
    
    private var quantity: Double {
        flowState.shares.filter {
            $0.itemID == item.id
        }.reduce(0) { partialResult, curr in
            return partialResult + curr.realQuantity
        }
    }
    
    private var payers: [Payer] {
        flowState.shares.filter {
            $0.itemID == item.id
        }.compactMap { share in
            flowState.payers.first {
                $0.id == share.payerID
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(item.name)
                Spacer()
                Text("\(item.price.formatted(.currency(code: currency.rawValue)))")
                    .monospacedDigit()
                    .bold()
                if quantity != 0 {
                    Text("× \(quantity.roundedToTwoPlaces)")
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
            }
            HStack(alignment: .bottom) {
                if payers.isEmpty {
                    Label("No payers assigned", systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                        .font(.caption)
                } else {
                    PayerShareList(
                        item: item,
                        payers: payers,
                        flowState: $flowState,
                        indexOfShareToEdit: $indexOfShareToEdit
                    )
                }
                Spacer()
                CreateShareMenu(
                    item: item,
                    assignedPayers: payers,
                    indexOfShareToEdit: $indexOfShareToEdit,
                    flowState: $flowState,
                    createNewPayerAction: createNewPayerAction
                )
                .buttonStyle(.bordered)
            }
            .disabled(isEditing)
        }
        .id(item.id)
        .sheet(item: $indexOfShareToEdit) { i in
            QuantityEditorSheet(
                itemName: item.name,
                payerName: payers.first { $0.id == flowState.shares[i].payerID }?.name ?? "-",
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

private struct PayerShareList: View {
    let item: Item
    let payers: [Payer]
    @Binding var flowState: SplitterFlowState
    @Binding var indexOfShareToEdit: [Share].Index?
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(payers) { payer in
                ShareButton(
                    title: payer.name,
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
    let item: Item
    let assignedPayers: [Payer]
    @Binding var indexOfShareToEdit: [Share].Index?
    @Binding var flowState: SplitterFlowState
    let createNewPayerAction: (() -> Void)?
    
    @State private var isPresentingMultiSelectMenu = false
    
    var body: some View {
        Menu {
            Section {
                Button("Add New") {
                    createNewPayerAction?()
                }
                Button("Select Multiple") {
                    isPresentingMultiSelectMenu = true
                }
            }
            Section {
                ForEach(flowState.payers) { payer in
                    Button(payer.name) {
                        let newShare = Share(payerID: payer.id, itemID: item.id)
                        flowState.shares.append(newShare)
                        let i = flowState.shares.firstIndex {
                            $0.id == newShare.id
                        }!
                        indexOfShareToEdit = i
                    }
                    .disabled(assignedPayers.contains { $0.id == payer.id })
                }
            }
        } label: {
            Label("Assign payer", systemImage: "plus")
                .labelStyle(.iconOnly)
        }
        .sheet(isPresented: $isPresentingMultiSelectMenu) {
            MultiSelectSheet(
                data: .payers(item: item),
                flowState: $flowState,
                isPresenting: $isPresentingMultiSelectMenu
            )
        }
    }
}

struct ItemRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ForEach(SplitterFlowState.sampleData.items) { item in
                ItemRow(flowState: .constant(SplitterFlowState.sampleData), item: .constant(item), currency: .jpy)
            }
        }
    }
}
