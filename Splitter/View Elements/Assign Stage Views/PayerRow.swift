import SwiftUI

struct PayerRow: View {
    @Binding var flowState: SplitterFlowState
    @Binding var payer: Payer
    
    @Environment(\.editMode) private var editMode
    
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
                        isPresentingPayerEditorSheet = true
                    } label: {
                        Image(systemName: "pencil")
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .id(payer.id)
        .sheet(isPresented: $isPresentingPayerEditorSheet) {
            PayerEditor(
                payer: $payer,
                shares: $flowState.shares,
                items: flowState.items
            ) {
                isPresentingPayerEditorSheet = false
            }
            .presentationDetents([.medium])
            .presentationBackground(.thinMaterial)
            .interactiveDismissDisabled()
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
