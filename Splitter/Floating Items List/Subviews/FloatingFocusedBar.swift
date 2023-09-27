//
//  FloatingFocusedBar.swift
//  OCRTestApp
//
//  Created by Vincent C. on 9/19/23.
//

import SwiftUI

struct FloatingFocusedBar: View {
    let item: Item.Initiation
    @Binding var items: [Item]
    @Binding var state: FloatingBarState
    let currency: Currency
    
    var body: some View {
        HStack {
            ItemPropertyField(item: item, fieldType: .name, state: $state)
            Spacer()
            ItemPropertyField(item: item, fieldType: .price(currency), state: $state)
            CancelButton(state: $state)
            ConfirmButton(item: item, items: $items, state: $state)
        }
    }
}

private struct CancelButton: View {
    @Binding var state: FloatingBarState
    
    var body: some View {
        Button {
            state = .minimized
        } label: {
            Label("Cancel", systemImage: "multiply.circle")
                .labelStyle(.iconOnly)
                .font(.title)
        }
        .foregroundStyle(.gray)
    }
}

private struct ConfirmButton: View {
    let item: Item.Initiation
    @Binding var items: [Item]
    @Binding var state: FloatingBarState
    
    var body: some View {
        if let completedItem = Item(from: item) {
            Button {
                if let replacementIndex = item.replacementIndex {
                    items[replacementIndex] = completedItem
                    state = .minimized
                } else {
                    items.append(completedItem)
                    state = .minimized
                }
            } label: {
                Label("Confirm", systemImage: "checkmark.circle.fill")
                    .labelStyle(.iconOnly)
                    .font(.title)
            }
        } else {
            Button {} label: {
                Label("Confirm", systemImage: "checkmark.circle.fill")
                    .labelStyle(.iconOnly)
                    .font(.title)
            }
            .disabled(true)
        }
    }
}

#Preview {
    ReceiptStage(items: [
        .init(name: "hello", price: 9.99),
        .init(name: "たこわさ", price: 7.99)
    ])
}
