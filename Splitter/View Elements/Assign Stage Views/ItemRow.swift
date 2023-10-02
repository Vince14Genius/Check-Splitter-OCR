import SwiftUI

struct ItemRow: View {
    @Binding var flowState: SplitterFlowState
    @Binding var item: Item
    @State private var isEditingPrice = false
    
    let currency: Currency
    var createNewPayerAction: (() -> Void)?
    
    @Environment(\.editMode) private var editMode
    @State private var shareToEdit: Binding<Share>?
    
    private var quantity: Double {
        let shares = flowState.shares.filter {
            $0.itemID == item.id
        }

        return shares.reduce(0) { partialResult, curr in
            return partialResult + curr.realQuantity
        }
    }
    
    private var payers: [Payer] {
        let payerIDs = flowState.shares.filter {
            $0.itemID == item.id
        }.map { $0.payerID }
        var output = [Payer]()
        
        for payerID in payerIDs {
            let payer = flowState.payers.first {
                $0.id == payerID
            } 
            if let payer {
                output.append(payer)
            }
        }
        
        return output
    }
    
    private var isEditing: Bool {
        return editMode?.wrappedValue.isEditing ?? false
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
            if !isEditing {
                HStack {
                    if payers.isEmpty {
                        Label("No payers assigned", systemImage: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Spacer()
                        Button {
                            createNewPayerAction?()
                        } label: {
                            Image(systemName: "plus")
                        }
                    } else {
                        PayerShareList(
                            shareToEdit: $shareToEdit,
                            item: item,
                            payers: payers,
                            flowState: $flowState
                        )
                        if !isEditing {
                            Button {
                                //TODO
                            } label: {
                                Image(systemName: "pencil")
                            }
                            CreateShareMenu(
                                item: $item,
                                shareToEdit: $shareToEdit,
                                flowState: $flowState,
                                payers: payers,
                                createNewPayerAction: createNewPayerAction
                            )
                        }
                    }
                }
            }
        }
        .id(item.id)
        .sheet(item: $shareToEdit) { $share in
            QuantityEditorSheet(
                itemName: item.name,
                payerName: payers.first { $0.id == share.payerID }?.name ?? "-",
                share: $share
            ) {
                shareToEdit = nil
            }
        }
    }
}

private struct PayerShareList: View {
    @Binding var shareToEdit: Binding<Share>?
    let item: Item
    let payers: [Payer]
    @Binding var flowState: SplitterFlowState
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(payers) { payer in
                    Button(payer.name) {
                        // if payer is shown on the list
                        // then the corresponding share is
                        // guaranteed to be present
                        let i = flowState.shares.firstIndex {
                            $0.itemID == item.id &&
                            $0.payerID == payer.id
                        }!
                        shareToEdit = $flowState.shares[i]
                    }
                    .buttonStyle(.bordered)
                    .foregroundStyle(.primary)
                }
            }
        }
    }
}

private struct CreateShareMenu: View {
    @Binding var item: Item
    @Binding var shareToEdit: Binding<Share>?
    @Binding var flowState: SplitterFlowState
    let payers: [Payer]
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
                    if !payers.contains(where:  { $0.id == payer.id }) {
                        Button(payer.name) {
                            let newShare = Share(payerID: payer.id, itemID: item.id)
                            flowState.shares.append(newShare)
                            let i = flowState.shares.firstIndex {
                                $0.id == newShare.id
                            }!
                            shareToEdit = $flowState.shares[i]
                        }
                    }
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
