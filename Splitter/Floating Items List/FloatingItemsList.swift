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
    
    private var shouldShowRedBorder: Bool {
        switch state {
        case .minimized:
            items.isEmpty
        case .expanded, .focused(_):
            false
        }
    }
    
    private var shouldShowRedTitle: Bool {
        switch state {
        case .expanded:
            items.isEmpty
        case .minimized, .focused(_):
            false
        }
    }
    
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
                    VStack {
                        Divider()
                        if items.isEmpty {
                            Spacer()
                            Text("No items yet.")
                                .foregroundStyle(shouldShowRedTitle ? .red : .primary)
                            Spacer()
                        } else {
                            FloatingExpandedList(items: $items, state: $state, currency: currency)
                        }
                    }
                    .overlay(alignment: .bottom) {
                        NewItemButton(state: $state)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.regularMaterial)
                    .stroke(shouldShowRedBorder ? Color.red : .primary.opacity(0.1))
            )
        }
        .frame(maxWidth: 500)
    }
}

#Preview {
    ContentView(items: [
        .init(name: "hello", price: 9.99),
        .init(name: "たこわさ", price: 7.99)
    ])
}
