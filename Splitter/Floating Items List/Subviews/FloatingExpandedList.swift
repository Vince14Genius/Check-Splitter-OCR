//
//  FloatingExpandedList.swift
//  OCRTestApp
//
//  Created by Vincent C. on 9/19/23.
//

import SwiftUI

struct FloatingExpandedList: View {
    @Binding var items: [Item]
    @Binding var state: FloatingBarState
    let currency: Currency
    let shouldShowRedTitle: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            ScrollView(.vertical) {
                VStack {
                    InstructionsBanner(text: "To create items, tap on item names and price numbers from your scanned receipt. Or do it manually here.")
                        .padding(.top)
                    if items.isEmpty {
                        Text("No items yet.")
                            .foregroundStyle(shouldShowRedTitle ? .red : .primary)
                            .padding()
                    } else {
                        InnerList(items: $items, state: $state, currency: currency)
                    }
                }
            }
            Divider()
            NewItemButton(state: $state)
        }
        .frame(maxHeight: 500)
        .transition(
            .scale(scale: 0, anchor: .topTrailing)
            .combined(with: .opacity)
        )
    }
}

private struct InnerList: View {
    @Binding var items: [Item]
    @Binding var state: FloatingBarState
    let currency: Currency
    
    var body: some View {
        VStack {
            Divider()
            ForEach(items.indices, id: \.self) { i in
                let item = items[i]
                HStack {
                    ItemRowButton(item: item, replacementIndex: i, state: $state, currency: currency)
                    Divider()
                    ItemDeleteButton(item: item, items: $items)
                }
                Divider()
            }
        }
        .padding(.vertical)
    }
}

private struct ItemDeleteButton: View {
    let item: Item
    @Binding var items: [Item]
    
    var body: some View {
        Button(role: .destructive) {
            items.removeAll { $0.id == item.id }
        } label: {
            Label("Delete", systemImage: "trash")
                .labelStyle(.iconOnly)
        }
    }
}

#Preview {
    ReceiptStage(items: [
        .init(name: "hello", price: 9.99),
        .init(name: "たこわさ", price: 7.99)
    ])
}
