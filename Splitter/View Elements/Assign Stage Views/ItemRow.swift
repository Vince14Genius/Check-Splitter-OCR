import SwiftUI

struct ItemRow: View {
    @Binding var flowState: SplitterFlowState
    @Binding var item: Item
    @State private var isEditingPrice = false
    
    let currency: Currency
    var createNewPayerAction: (() -> Void)?
    
    @State private var indexOfShareToEdit: [Share].Index?
    
    private var quantity: Double {
        flowState.shares.filter {
            $0.has(item)
        }.reduce(0) { partialResult, curr in
            return partialResult + curr.realQuantity
        }
    }
    
    private var payers: [Payer] {
        flowState.shares.filter {
            $0.has(item)
        }.compactMap { share in
            flowState.payers.first {
                share.has($0)
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Group {
                    Text(item.name)
                    Spacer()
                    Text("\(item.price.formatted(.currency(code: currency.rawValue)))")
                        .monospacedDigit()
                }
                    .font(.title2)
                if quantity != 0 {
                    Text("× \(quantity.roundedToTwoPlaces)")
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                }
            }
            HStack {
                if payers.isEmpty {
                    Label("No payers assigned", systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                    Spacer()
                } else {
                    PayerShareList(
                        item: item,
                        payers: payers,
                        flowState: $flowState,
                        indexOfShareToEdit: $indexOfShareToEdit
                    )
                }
                CreateShareMenu(
                    item: item,
                    assignedPayers: payers,
                    indexOfShareToEdit: $indexOfShareToEdit,
                    flowState: $flowState,
                    createNewPayerAction: createNewPayerAction
                )
            }
        }
        .id(item.id)
        .sheet(item: $indexOfShareToEdit) { i in
            QuantityEditorSheet(
                itemName: item.name,
                payerName: payers.first { flowState.shares[i].has($0) }?.name ?? "-",
                share: $flowState.shares[i]
            ) {
                indexOfShareToEdit = nil
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
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(payers) { payer in
                    ShareButton(
                        title: payer.name,
                        item: item,
                        payer: payer,
                        flowState: $flowState,
                        indexOfShareToEdit: $indexOfShareToEdit
                    )
                }
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
    
    var body: some View {
        Menu {
            Section {
                Button("Add New") {
                    createNewPayerAction?()
                }
            }
            Section {
                ForEach(flowState.payers) { payer in
                    Button(payer.name) {
                        let newShare = Share.from(item: item, payer: payer)
                        flowState.shares.append(newShare)
                        let i = flowState.shares.firstIndex {
                            $0 == newShare
                        }!
                        indexOfShareToEdit = i
                    }
                    .disabled(assignedPayers.contains { $0 == payer })
                }
            }
        } label: {
            Image(systemName: "plus")
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
