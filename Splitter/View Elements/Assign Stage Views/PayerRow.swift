import SwiftUI

struct PayerRow: View {
    @Binding var flowState: SplitterFlowState
    @Binding var payer: Payer
    
    @Environment(\.editMode) private var editMode
    
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
            Group {
                if isEditing {
                    NameLabel(payer.name)
                } else {
                    TextField("Payer Name", text: $payer.name)
                }
            }
                .font(.title2)
            HStack {
                Text("\(items.count) items")
                    .foregroundColor(.secondary)
                    .font(.body.monospacedDigit())
                Spacer()
                if !isEditing {
                    Button {
                        
                    } label: {
                        Image(systemName: "pencil")
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .id(payer.id)
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
