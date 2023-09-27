//
//  ItemRowButton.swift
//  Splitter
//
//  Created by Vincent C. on 9/24/23.
//

import SwiftUI

struct ItemRowButton: View {
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
                .monospacedDigit()
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

#Preview {
    ItemRowButton(item: .init(name: "Sample", price: 9.99), replacementIndex: 0, state: .constant(.expanded), currency: .gbp)
}
