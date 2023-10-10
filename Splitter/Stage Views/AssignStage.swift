//
//  AssignStage.swift
//  Splitter
//
//  Created by Vincent C. on 9/26/23.
//

import SwiftUI

struct AssignStage: View {
    enum ViewMode: String, CaseIterable {
        case items = "Items"
        case payers = "Payers"
    }
    
    @Binding var stage: Stage
    @Binding var path: [InfoEntryStage]
    @Binding var flowState: SplitterFlowState
    let currency: Currency
    
    @State private var viewMode: ViewMode = .items
    @State private var payerToEdit: Payer = .init(name: "")
    @State private var isPresentingPayerEditor = false
    
    private func createNewPayer() {
        // payerToEdit is reset on every sheet dismissal,
        // so simply present the sheet
        isPresentingPayerEditor = true
    }
    
    var body: some View {
        TabView(selection: $viewMode) {
            List {
                ForEach($flowState.items) { $item in
                    ItemRow(
                        flowState: $flowState,
                        item: $item,
                        currency: currency
                    ) {
                        createNewPayer()
                        flowState.shares.append(
                            .init(payerID: payerToEdit.id, itemID: item.id)
                        )
                    }
                }
            }
            .tag(ViewMode.items)
            List {
                if flowState.payers.isEmpty {
                    HStack {
                        Spacer()
                        Label {
                            Text("No payers yet.")
                        } icon: {
                            Image(systemName: "exclamationmark.triangle.fill")
                        }
                            .foregroundStyle(.red)
                        Spacer()
                    }
                }
                ForEach($flowState.payers) { $payer in
                    PayerRow(flowState: $flowState, payer: $payer)
                }
                .onDelete { flowState.payers.remove(atOffsets: $0) }
                .onMove { flowState.payers.move(fromOffsets: $0, toOffset: $1) }
            }
            .tag(ViewMode.payers)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .ignoresSafeArea(edges: [.top, .bottom])
        .background(Color(.systemGroupedBackground))
        .animation(.easeInOut(duration: 0.3), value: viewMode)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                AssignStageNavBar(isNextButtonEnabled: flowState.canCalculate, stage: $stage, path: $path)
            }
            ToolbarItem(placement: .principal) {
                Picker("View Mode", selection: $viewMode) {
                    ForEach(ViewMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
            }
            ToolbarItem(placement: .topBarLeading) {
                EditButton()
                    .disabled({
                        switch viewMode {
                        case .items: true
                        case .payers: false
                        }
                    }())
            }
            ToolbarItem(placement: .topBarTrailing) {
                switch viewMode {
                case .items:
                    Button {} label: {
                        Image(systemName: "plus").disabled(true)
                    }
                case .payers:
                    Button {
                        createNewPayer()
                    } label: {
                        Label("Create new payer", systemImage: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $isPresentingPayerEditor) {
            PayerEditor(
                payer: $payerToEdit,
                flowState: $flowState
            ) {
                defer {
                    payerToEdit = .init(name: "")
                    isPresentingPayerEditor = false
                }
                guard !payerToEdit.name.isEmpty else {
                    return
                }
                if let i = flowState.payers.firstIndex(where: { $0.id == payerToEdit.id }) {
                    // editing existing payer
                    flowState.payers[i] = payerToEdit
                } else {
                    // adding new payer
                    flowState.payers.append(payerToEdit)
                }
            }
            .presentationDetents([.medium])
            .presentationBackground(.thinMaterial)
            .interactiveDismissDisabled()
        }
    }
}

#Preview {
    NavigationStack {
        AssignStage(stage: .constant(.infoEntry), path: .constant([.assignPayers]), flowState: .constant(.sampleData), currency: .try)
    }
}
