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
    
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                ForEach(items.indices, id: \.self) { i in
                    let item = items[i]
                    HStack {
                        Button {
                            state = .focused(item: .init(
                                name: item.name,
                                price: item.price,
                                replacementIndex: i
                            ))
                        } label: {
                            Text(item.name)
                                .foregroundStyle(Color(.label))
                            Spacer()
                            Text(item.price.formatted(.currency(code: "usd")))
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.accentColor)
                                )
                                .foregroundStyle(.background)
                        }
                        
                        Divider()
                        
                        Button(role: .destructive) {
                            items.removeAll { $0.id == item.id }
                        } label: {
                            Label("Delete", systemImage: "trash")
                                .labelStyle(.iconOnly)
                        }
                    }
                    .font(.title2)
                    Divider()
                }
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
