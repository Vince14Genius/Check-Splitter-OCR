//
//  ItemsListSheet.swift
//  Splitter
//
//  Created by Vincent C. on 9/19/23.
//

import SwiftUI

struct ItemsListSheet: View {
    @Binding var items: [Item]
    @Binding var state: FloatingBarState
    let currency: Currency
    let shouldShowRedTitle: Bool
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationStack {
            List {
                if items.isEmpty {
                    InstructionsBanner(text: "To create items, tap on item names and price numbers from your scanned receipt. Or do it manually here.")
                        .listRowBackground(Color.clear)
                    Centered {
                        Text("No items yet.")
                    }
                    .foregroundStyle(shouldShowRedTitle ? .red : .primary)
                    .listRowBackground(Color.clear)
                } else {
                    InnerList(items: $items, state: $state, currency: currency, isPresented: $isPresented)
                }
            }
            .navigationTitle("Items")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        EditButton()
                        Spacer()
                        Button {
                            state = .focused(item: .init())
                            isPresented = false
                        } label: {
                            Label("Add new item", systemImage: "plus")
                                .labelStyle(.iconOnly)
                        }
                    }
                }
            }
        }
    }
}

private struct InnerList: View {
    @Binding var items: [Item]
    @Binding var state: FloatingBarState
    let currency: Currency
    @Binding var isPresented: Bool
    
    var body: some View {
        ForEach(items.indices, id: \.self) { i in
            let item = items[i]
            ItemRowButton(
                item: item,
                replacementIndex: i,
                state: $state,
                currency: currency,
                isPresented: $isPresented
            )
        }
        .onDelete { items.remove(atOffsets: $0) }
        .onMove { items.move(fromOffsets: $0, toOffset: $1) }
    }
}

#Preview {
    StageSwitcherView(flowState: .sampleData)
}
