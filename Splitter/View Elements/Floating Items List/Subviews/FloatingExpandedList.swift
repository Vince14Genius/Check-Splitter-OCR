//
//  FloatingExpandedList.swift
//  Splitter
//
//  Created by Vincent C. on 9/19/23.
//

import SwiftUI

struct FloatingExpandedList: View {
    @Binding var items: [Item]
    @Binding var state: FloatingBarState
    let currency: Currency
    let shouldShowRedTitle: Bool
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationStack {
            List {
                InstructionsBanner(text: "To create items, tap on item names and price numbers from your scanned receipt. Or do it manually here.")
                    .listRowBackground(Color.clear)
                if items.isEmpty {
                    Centered {
                        Text("No items yet.")
                    }
                    .foregroundStyle(shouldShowRedTitle ? .red : .primary)
                    .listRowBackground(Color.clear)
                } else {
                    InnerList(items: $items, state: $state, currency: currency, isPresented: $isPresented)
                        .listRowBackground(Color.clear)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Items")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    EditButton()
                }
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        state = .focused(item: .init())
                        isPresented = false
                    } label: {
                        Image(systemName: "plus")
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
