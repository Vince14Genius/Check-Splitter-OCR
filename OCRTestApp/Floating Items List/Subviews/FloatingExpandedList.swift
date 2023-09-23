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
    
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                ForEach(items.indices, id: \.self) { i in
                    let item = items[i]
                    HStack {
                        ItemRowButton(item: item, replacementIndex: i, state: $state, currency: currency)
                        Divider()
                        ItemDeleteButton(item: item, items: $items)
                    }
                    .font(.title2)
                    Divider()
                }
            }
        }
    }
}

private struct ItemRowButton: View {
    let item: Item
    let replacementIndex: [Item].Index
    @Binding var state: FloatingBarState
    let currency: Currency
    
    var body: some View {
        Button {
            state = .focused(item: .init(
                name: item.name,
                price: item.price,
                replacementIndex: replacementIndex
            ))
        } label: {
            Text(item.name)
                .foregroundStyle(Color(.label))
            Spacer()
            Text(item.price.formatted(.currency(code: currency.rawValue)))
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.accentColor)
                )
                .foregroundStyle(.background)
        }
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
    ContentView(items: [
        .init(name: "hello", price: 9.99),
        .init(name: "たこわさ", price: 7.99)
    ])
}
