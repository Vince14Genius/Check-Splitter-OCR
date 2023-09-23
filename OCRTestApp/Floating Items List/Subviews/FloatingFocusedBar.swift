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
            ItemPropertyField(item: item, fieldType: .name)
            Spacer()
            ItemPropertyField(item: item, fieldType: .price(currency))
            CancelButton(state: $state)
            ConfirmButton(item: item, items: $items, state: $state)
        }
    }
}

private struct ItemPropertyField: View {
    enum FieldType {
        case name
        case price(Currency)
    }
    
    let item: Item.Initiation
    let fieldType: FieldType
    
    private var themeColor: Color {
        switch fieldType {
        case .name:
            .blue
        case .price(_):
            .green
        }
    }
    
    var body: some View {
        Group {
            switch fieldType {
            case .name:
                if let name = item.name {
                    Text(name)
                } else {
                    Text("")
                }
            case .price(let currency):
                if let price = item.price {
                    Text(price.formatted(.currency(code: currency.rawValue)))
                } else {
                    Text("")
                }
            }
        }
        .font(.headline)
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(themeColor.opacity(0.3))
        )
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
    ContentView(items: [
        .init(name: "hello", price: 9.99),
        .init(name: "たこわさ", price: 7.99)
    ])
}
