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
    
    var body: some View {
        HStack {
            Group {
                Group {
                    if let name = item.name {
                        Text(name)
                    } else {
                        Text("")
                    }
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(.blue.opacity(0.3))
                )
                Spacer()
                Group {
                    if let price = item.price {
                        Text(price.formatted(.currency(code: "usd")))
                    } else {
                        Text("")
                    }
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(.green.opacity(0.3))
                )
            }
            .font(.headline)
            
            Button {
                state = .minimized
            } label: {
                Label("Cancel", systemImage: "multiply.circle")
                    .labelStyle(.iconOnly)
                    .font(.title)
            }
            .foregroundStyle(.gray)
            
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
}

#Preview {
    ContentView(items: [
        .init(name: "hello", price: 9.99),
        .init(name: "たこわさ", price: 7.99)
    ])
}
