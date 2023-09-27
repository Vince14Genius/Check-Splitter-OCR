//
//  FloatingItemsList.swift
//  Splitter
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
            Spacer(minLength: 0)
            HStack {
                if state == .minimized {
                    Spacer()
                }
                InnerBar(items: $items, state: $state, currency: currency)
            }
            .frame(maxWidth: 500)
        }
    }
}

private struct InnerBar: View {
    @Binding var items: [Item]
    @Binding var state: FloatingBarState
    let currency: Currency
    
    private var shouldShowRedIndicator: Bool {
        switch state {
        case .expanded, .minimized:
            items.isEmpty
        case .focused(_):
            false
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            if case .focused(let item) = state {
                FloatingFocusedBar(
                    item: item,
                    items: $items,
                    state: $state,
                    currency: currency
                )
            } else {
                HStack {
                    Text("**\(items.count)** items")
                        .font(state == .expanded ? .headline : .body)
                    if case .expanded = state {
                        Spacer()
                    }
                    FoldButton(state: $state)
                }
                .font(.title)
            }
            
            if case .expanded = state {
                FloatingExpandedList(
                    items: $items,
                    state: $state,
                    currency: currency,
                    shouldShowRedTitle: shouldShowRedIndicator
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
                .stroke(shouldShowRedIndicator ? Color.red : .primary.opacity(0.1))
        )
    }
}

private struct FoldButton: View {
    @Binding var state: FloatingBarState
    
    var body: some View {
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
                .font(.body)
        }
    }
}

#Preview {
    ReceiptStage(items: [
        .init(name: "hello", price: 9.99),
        .init(name: "たこわさ", price: 7.99)
    ])
}
