//
//  FloatingItemsList.swift
//  OCRTestApp
//
//  Created by Vincent C. on 9/3/23.
//

import SwiftUI

struct FloatingItemsList: View {
    @Binding var items: [Item]
    @Binding var state: FloatingBarState
    let currency: Currency
    
    var body: some View {
        HStack {
            if state != .expanded {
                Spacer()
            }
            VStack {
                if case .focused(let item) = state {
                    FloatingFocusedBar(item: item, items: $items, state: $state, currency: currency)
                } else {
                    HStack {
                        Text("\(items.count) items")
                            .font(state == .expanded ? .title.bold() : .title)
                        
                        if case .expanded = state {
                            Spacer()
                        }
                        
                        Button {
                            switch state {
                            case .minimized:
                                state = .expanded
                            case .expanded:
                                state = .minimized
                            default: fatalError("Invalid floating button state")
                            }
                        } label: {
                            Image(systemName: "chevron.down.circle")
                                .rotationEffect(state == .expanded ? .degrees(180) : .zero)
                        }
                    }
                    .font(.title)
                }
                
                if case .expanded = state {
                    Divider()
                    if items.isEmpty {
                        Text("No items yet.")
                    } else {
                        FloatingExpandedList(items: $items, state: $state, currency: currency)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.regularMaterial)
                    .stroke(.primary.opacity(0.1))
            )
        }
        .frame(maxWidth: 400)
    }
}

#Preview {
    ContentView(items: [
        .init(name: "hello", price: 9.99),
        .init(name: "たこわさ", price: 7.99)
    ])
}
